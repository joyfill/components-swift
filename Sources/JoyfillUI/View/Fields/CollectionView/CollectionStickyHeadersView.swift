//
//  CollectionStickyHeadersView.swift
//  Joyfill
//

import SwiftUI

/// Holds the grid's vertical offset. Kept out of the modal's observed state so a
/// scroll tick only invalidates the sticky overlay, never the grid itself.
final class CollectionStickyScrollTracker: ObservableObject {
    @Published private(set) var offsetY: CGFloat = 0

    /// Bumped on every view-model change, so pinned rows rebuild when their content can
    /// have changed (edits, selection, sort, expand/collapse) but never on a scroll tick.
    var revision = 0

    /// Owners of the rows at the top; recomputed when the top row or the data change.
    var cachedOwners: (key: [Int], owners: [(block: CollectionStickyHeadersView.Block, y: CGFloat)])?

    /// Root table width, recomputed only when the data revision changes.
    var cachedRootWidth: (revision: Int, width: CGFloat)?

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
                // Synchronous: contentOffset KVO fires on main, and a hop would make the header lag a frame.
                self?.tracker.update(y)
            }
        }
    }
}

/// Pins the header of whichever table the top row belongs to: the root title + columns, or
/// one nested table's title + columns. Every change works the same way, like UITableView
/// section headers: the next table's header rises from below and pushes the current one up
/// and out, whether a nested table is starting, ending back into its parent, or ending into
/// root. Drawn inside the scroll content so horizontal scrolling stays in sync; on a scroll
/// tick only y offsets change.
struct CollectionStickyHeadersView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @ObservedObject var tracker: CollectionStickyScrollTracker
    let rootTitle: AnyView
    let rootColumns: AnyView
    let rowBuilder: (Int) -> AnyView
    @Environment(\.colorScheme) private var colorScheme

    /// Every row in the grid (title, headers, rows, expanders) is this tall.
    static let rowHeight: CGFloat = 60
    /// Title row (60) + root column header (60 + 1pt vertical padding on each side).
    static let titleHeight: CGFloat = 60
    static let rootHeaderHeight: CGFloat = 62
    static var firstRowY: CGFloat { titleHeight + rootHeaderHeight }

    private func cachedRootWidth(revision: Int) -> CGFloat {
        if let cached = tracker.cachedRootWidth, cached.revision == revision { return cached.width }
        let model = viewModel.tableDataModel
        let width = viewModel.rowWidth(model.tableColumns, 0, viewModel.rootSchemaKey, tableDataModel: model)
        tracker.cachedRootWidth = (revision, width)
        return width
    }

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

    var body: some View {
        let offset = tracker.offsetY
        let revision = tracker.revision
        Group {
            if offset > 0 {
                let placed = placedBlocks(offset: offset, revision: revision)
                ZStack(alignment: .topLeading) {
                    // Root stays in the tree (hidden when not pinned) so it never rebuilds mid-scroll.
                    let root = placed.first(where: { $0.block.isRoot })
                    let rootY = root?.y ?? offset
                    let rootWidth = cachedRootWidth(revision: revision)
                    StickyRows(indices: [], revision: revision, colorScheme: colorScheme,
                               rootTitle: rootTitle, rootColumns: rootColumns, rowBuilder: rowBuilder)
                        .equatable()
                        .frame(width: rootWidth, alignment: .leading)
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

    /// The current header pinned at the top, and the next one once it's within reach:
    /// - Next table starts (its title row is right there): it rises with its real row and
    ///   pushes the current header up and out.
    /// - Current table ends (next row belongs to the parent or root): the current header rides
    ///   up and away with its last row, revealing the parent's header already pinned beneath.
    /// Blocks are returned bottom layer first.
    private func placedBlocks(offset: CGFloat, revision: Int) -> [(block: Block, y: CGFloat)] {
        let models = viewModel.tableDataModel.filteredcellModels
        let owners = upcomingOwners(offset: offset, revision: revision, models: models)
        guard let current = owners.first?.block else { return [(Block.root, offset)] }
        let reach = offset + current.height
        guard let next = owners.dropFirst().first(where: { $0.block != current && $0.y < reach }) else {
            return [(current, offset)]
        }
        let leavingY = min(offset, next.y - current.height)
        let nextStartsHere = !next.block.isRoot && next.block.key == Int((next.y - Self.firstRowY) / Self.rowHeight)
        if nextStartsHere {
            return [(current, leavingY), (next.block, next.y)]
        }
        return [(next.block, offset), (current, leavingY)]
    }

    /// Owner of the top row and of the few rows below it (all a pinned block can span), with
    /// each row's content y. Owners take a walk up the section, so this is cached until the
    /// top row or the data changes.
    private func upcomingOwners(offset: CGFloat, revision: Int, models: [RowDataModel]) -> [(block: Block, y: CGFloat)] {
        guard viewModel.nestedTableCount > 0, !models.isEmpty else { return [] }
        // Above the first row the viewport top is still inside the real root header (-1).
        let top = offset < Self.firstRowY ? -1 : min(Int((offset - Self.firstRowY) / Self.rowHeight), models.count - 1)
        let key = [top, revision]
        if let cached = tracker.cachedOwners, cached.key == key { return cached.owners }
        let current = top < 0 ? Block.root : Self.owner(of: top, in: models)
        let first = top + 1
        let last = min(top + Int(Block.root.height / Self.rowHeight) + 1, models.count - 1)
        let below = first <= last ? (first...last).map { i in
            (block: Self.owner(of: i, in: models), y: Self.firstRowY + CGFloat(i) * Self.rowHeight)
        } : []
        let owners = [(block: current, y: offset)] + below
        tracker.cachedOwners = (key, owners)
        return owners
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
    var rootTitle: AnyView? = nil
    var rootColumns: AnyView? = nil
    let rowBuilder: (Int) -> AnyView

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.indices == rhs.indices && lhs.revision == rhs.revision && lhs.colorScheme == rhs.colorScheme
            && (lhs.rootTitle == nil) == (rhs.rootTitle == nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let rootTitle, let rootColumns {
                rootTitle
                rootColumns
            }
            ForEach(Array(indices.enumerated()), id: \.element) { i, index in
                rowBuilder(index)
            }
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
