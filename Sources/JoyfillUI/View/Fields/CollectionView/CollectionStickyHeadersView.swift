//
//  CollectionStickyHeadersView.swift
//  Joyfill
//

import SwiftUI

/// Fixed grid geometry the sticky headers rely on. Must match the grid's 60pt row literals.
enum CollectionGridMetrics {
    /// Every grid row (rows, nested headers, expanders) is this tall.
    static let rowHeight: CGFloat = 60
    static let titleHeight: CGFloat = 60
    static let rootHeaderHeight: CGFloat = 60
}

/// Holds the grid's vertical offset. Kept out of the modal's observed state so a
/// scroll tick only invalidates the sticky overlay, never the grid itself.
final class CollectionStickyScrollTracker: ObservableObject {
    @Published private(set) var offsetY: CGFloat = 0

    /// Bumped on every view-model change (rows live in @Published tableDataModel), never on scroll.
    var revision = 0

    /// Current/next header and root width; recomputed only when the top row or the data change.
    var cache: (key: [Int], layout: CollectionStickyHeadersView.Layout)?

    func update(_ y: CGFloat) {
        // Non-finite offsets (zero-size layout passes) would crash the Int() conversions downstream.
        guard y.isFinite else { return }
        if y != offsetY { offsetY = y }
    }
}

/// Reads the vertical offset from the backing UIScrollView via KVO. A GeometryReader
/// preference doesn't re-fire while a two-axis ScrollView scrolls, and iOS 18's
/// onScrollGeometryChange on this ScrollView resets its horizontal offset on vertical scrolls.
/// Place it in the scroll content's background.
struct CollectionScrollOffsetReader: UIViewRepresentable {
    let tracker: CollectionStickyScrollTracker

    func makeUIView(context: Context) -> ReaderView { ReaderView(tracker: tracker) }
    func updateUIView(_ uiView: ReaderView, context: Context) {}

    final class ReaderView: UIView {
        let tracker: CollectionStickyScrollTracker
        private var observation: NSKeyValueObservation?
        private var lastContentSize: CGSize = .zero

        init(tracker: CollectionStickyScrollTracker) {
            self.tracker = tracker
            super.init(frame: .zero)
            isUserInteractionEnabled = false
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            observation = nil
            guard window != nil else { return }
            var view = superview
            while let current = view, !(current is UIScrollView) { view = current.superview }
            guard let scrollView = view as? UIScrollView else { return }
            observation = scrollView.observe(\.contentOffset, options: [.initial, .new]) { [weak self] scrollView, _ in
                let y = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
                // User scrolls: update now so the header never lags a frame. Layout-driven offset
                // changes fire inside a SwiftUI update, where publishing is not allowed, so defer those.
                // A content size change means layout moved the offset, even mid-scroll.
                guard let self else { return }
                let resized = scrollView.contentSize != self.lastContentSize
                self.lastContentSize = scrollView.contentSize
                if !resized && (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
                    self.tracker.update(y)
                } else {
                    DispatchQueue.main.async { [weak self] in self?.tracker.update(y) }
                }
            }
        }
    }
}

/// Pins the title + columns of the table owning the top row. Drawn inside the scroll content so
/// it scrolls horizontally with the grid; a scroll tick only changes y offsets.
struct CollectionStickyHeadersView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @ObservedObject var tracker: CollectionStickyScrollTracker
    let rootHeader: AnyView
    let rowBuilder: (Int) -> AnyView
    @Environment(\.colorScheme) private var colorScheme

    static let rowHeight = CollectionGridMetrics.rowHeight
    static let titleHeight = CollectionGridMetrics.titleHeight
    static let rootHeaderHeight = CollectionGridMetrics.rootHeaderHeight
    static var firstRowY: CGFloat { titleHeight + rootHeaderHeight }

    /// Square while a header is still arriving (it overlays its square real row), rounding to
    /// the card's 14pt as it reaches the top; stays rounded while pinned or leaving.
    static func cornerRadius(y: CGFloat, offset: CGFloat) -> CGFloat {
        max(0, PinnedHeaderChrome.maxRadius - max(0, y - offset))
    }

    /// A pinnable header: the root block, or a nested table's expander + column header rows.
    struct Block: Equatable {
        static let root = Block(key: -1, indices: [], height: titleHeight + rootHeaderHeight, width: 0)
        let key: Int          // expander row index; -1 for root
        let indices: [Int]
        let height: CGFloat
        let width: CGFloat    // header row's rowWidth (drawn nesting level); 0 = root
        var isRoot: Bool { key == -1 }
    }

    /// Header owning the top row, the next different one below it (if any), and root width.
    struct Layout {
        let current: Block
        let next: (block: Block, y: CGFloat)?
        let rootWidth: CGFloat
    }

    var body: some View {
        let offset = tracker.offsetY
        let revision = tracker.revision
        Group {
            if offset > 0 {
                let layout = cachedLayout(offset: offset, revision: revision)
                let placed = Self.placedBlocks(layout, offset: offset)
                ZStack(alignment: .topLeading) {
                    // Root stays in the tree (hidden when not pinned) so it never rebuilds mid-scroll.
                    let root = placed.first(where: { $0.block.isRoot })
                    let rootY = root?.y ?? offset
                    StickyRows(indices: [], revision: revision, colorScheme: colorScheme,
                               rootHeader: rootHeader, rowBuilder: rowBuilder)
                        .equatable()
                        .frame(width: layout.rootWidth, alignment: .leading)
                        .clipped()
                        .modifier(PinnedHeaderChrome(radius: Self.cornerRadius(y: rootY, offset: offset), colorScheme: colorScheme))
                        .offset(y: rootY)
                        .opacity(root == nil ? 0 : 1)
                        .allowsHitTesting(root != nil)
                    ForEach(placed.filter { !$0.block.isRoot }, id: \.block.key) { item in
                        StickyRows(indices: item.block.indices, revision: revision, colorScheme: colorScheme,
                                   rowBuilder: rowBuilder)
                            .equatable()
                            // Column rows span the whole collection; cut to this table's width.
                            .frame(width: item.block.width, alignment: .leading)
                            .clipped()
                            .modifier(PinnedHeaderChrome(radius: Self.cornerRadius(y: item.y, offset: offset), colorScheme: colorScheme))
                            .offset(y: item.y)
                    }
                }
                .accessibilityHidden(true)
            }
        }
        .onReceive(viewModel.objectWillChange) { _ in tracker.revision &+= 1 }
    }

    /// Next table starting: it rises with its real row and pushes the current header up.
    /// Current table ending: its header rides up with its last row, revealing the parent beneath.
    /// Returned bottom layer first.
    static func placedBlocks(_ layout: Layout, offset: CGFloat) -> [(block: Block, y: CGFloat)] {
        let current = layout.current
        guard let next = layout.next, next.y < offset + current.height else { return [(current, offset)] }
        let leavingY = min(offset, next.y - current.height)
        let nextStartsHere = !next.block.isRoot && next.block.key == Int((next.y - firstRowY) / rowHeight)
        if nextStartsHere {
            return [(current, leavingY), (next.block, next.y)]
        }
        return [(next.block, offset), (current, leavingY)]
    }

    /// Owner lookups walk up the section, so the result is cached per top row and data revision.
    private func cachedLayout(offset: CGFloat, revision: Int) -> Layout {
        let models = viewModel.tableDataModel.filteredcellModels
        // Above the first row the viewport top is still inside the real root header (-1).
        let top = offset < Self.firstRowY || models.isEmpty ? -1 : min(Int((offset - Self.firstRowY) / Self.rowHeight), models.count - 1)
        let key = [top, revision]
        if let cache = tracker.cache, cache.key == key { return cache.layout }

        let model = viewModel.tableDataModel
        let rootWidth = viewModel.rowWidth(model.tableColumns, 0, viewModel.rootSchemaKey, tableDataModel: model)
        var current = Block.root
        var next: (block: Block, y: CGFloat)?
        if viewModel.nestedTableCount > 0, !models.isEmpty {
            if top >= 0 { current = Self.owner(of: top, in: models) }
            // A pinned block spans at most the root header's rows, so look no further than that.
            let last = min(top + Int(Block.root.height / Self.rowHeight) + 1, models.count - 1)
            if top + 1 <= last {
                for i in (top + 1)...last {
                    let owner = Self.owner(of: i, in: models)
                    if owner != current { next = (owner, Self.firstRowY + CGFloat(i) * Self.rowHeight); break }
                }
            }
        }
        let layout = Layout(current: current, next: next, rootWidth: rootWidth)
        tracker.cache = (key, layout)
        return layout
    }

    /// The table a row belongs to. A nested table's title and column rows belong to that table.
    static func owner(of i: Int, in models: [RowDataModel]) -> Block {
        // Falls back to root unless expander/header are a real pair (rows can change mid-scroll).
        func nested(expander: Int) -> Block {
            guard expander >= 0, expander + 1 < models.count,
                  case .tableExpander = models[expander].rowType,
                  case .header = models[expander + 1].rowType else { return .root }
            return Block(key: expander, indices: [expander, expander + 1], height: 2 * rowHeight, width: models[expander + 1].rowWidth)
        }
        switch models[i].rowType {
        case .row:
            return .root
        case .tableExpander:
            return nested(expander: i)
        case .header:
            return nested(expander: i - 1)
        case .nestedRow(let level, _, _, _):
            var j = i - 1
            while j >= 0 {
                if case .header(let l, _, _) = models[j].rowType, l == level { return nested(expander: j - 1) }
                j -= 1
            }
            return .root
        }
    }
}

/// Pinned rows. Equatable on (rows, data revision, color scheme) so a scroll tick, which only moves them,
/// never rebuilds their content, while any data change does.
private struct StickyRows: View, Equatable {
    let indices: [Int]
    let revision: Int
    let colorScheme: ColorScheme
    var rootHeader: AnyView? = nil
    let rowBuilder: (Int) -> AnyView

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.indices == rhs.indices && lhs.revision == rhs.revision && lhs.colorScheme == rhs.colorScheme
            && (lhs.rootHeader == nil) == (rhs.rootHeader == nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let rootHeader { rootHeader }
            ForEach(indices, id: \.self) { rowBuilder($0) }
        }
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color(UIColor.systemBackground))
    }
}

/// Card corners, border and bottom fade for a pinned header. Kept outside StickyRows so the
/// radius can follow the scroll without rebuilding the rows.
private struct PinnedHeaderChrome: ViewModifier {
    static let maxRadius: CGFloat = 14 // matches RootTitleRowView's card corners
    let radius: CGFloat
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        content
            .cornerRadius(radius, corners: [.topLeft, .topRight], borderColor: Color.tableCellBorderColor)
            // Fade along the bottom edge only, exactly this header's width.
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [Color.black.opacity(colorScheme == .dark ? 0.35 : 0.10), .clear],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 6)
                    .offset(y: 6)
                    .allowsHitTesting(false)
            }
    }
}
