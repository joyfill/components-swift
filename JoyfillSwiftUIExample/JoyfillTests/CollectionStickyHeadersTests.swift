//
//  CollectionStickyHeadersTests.swift
//  JoyfillTests
//

import XCTest
import Combine
@testable import Joyfill

/// Pure-logic tests for the collection sticky headers: which table owns a row, where the pinned
/// headers sit while one table hands over to the next, and the pinned header's corner radius.
final class CollectionStickyHeadersTests: XCTestCase {
    typealias Sticky = CollectionStickyHeadersView

    private let rowH = CollectionGridMetrics.rowHeight
    private let maxRadius: CGFloat = 14

    // MARK: - Fixture

    /// Flat grid, the same shape CollectionViewModel builds:
    /// 0 root row
    /// 1   Depth 2 title (expander, level 0)     2   Depth 2 columns (header, level 1)
    /// 3   D2 row
    /// 4     Depth 3 title (expander, level 1)   5     Depth 3 columns (header, level 2)
    /// 6     D3 row
    /// 7   D2 row (Depth 2 continues after Depth 3)
    /// 8 root row
    private func nestedGrid() -> [RowDataModel] {
        [
            row(.row(index: 0)),
            row(.tableExpander(level: 0), width: 460),
            row(.header(level: 1, tableColumns: [], schemaKey: "d2"), width: 500),
            row(.nestedRow(level: 1, index: 0)),
            row(.tableExpander(level: 1), width: 500),
            row(.header(level: 2, tableColumns: [], schemaKey: "d3"), width: 540),
            row(.nestedRow(level: 2, index: 0)),
            row(.nestedRow(level: 1, index: 1)),
            row(.row(index: 1)),
        ]
    }

    /// Root row whose nested table is expanded but has no rows yet:
    /// 0 root row, 1 Depth 2 title, 2 Depth 2 columns, 3 root row
    private func emptyNestedGrid() -> [RowDataModel] {
        [
            row(.row(index: 0)),
            row(.tableExpander(level: 0), width: 460),
            row(.header(level: 1, tableColumns: [], schemaKey: "d2"), width: 500),
            row(.row(index: 1)),
        ]
    }

    private func row(_ type: RowType, width: CGFloat = 0) -> RowDataModel {
        RowDataModel(rowID: UUID().uuidString, cells: [], rowType: type, rowWidth: width)
    }

    private func y(ofRow i: Int) -> CGFloat {
        Sticky.firstRowY + CGFloat(i) * rowH
    }

    private func block(key: Int) -> Sticky.Block {
        Sticky.Block(key: key, indices: [key, key + 1], height: 2 * rowH, width: 500)
    }

    private func layout(_ current: Sticky.Block, next: (block: Sticky.Block, y: CGFloat)?) -> Sticky.Layout {
        Sticky.Layout(current: current, next: next, rootWidth: 600)
    }

    // MARK: - owner(of:in:)

    func testRootRowsBelongToRoot() {
        let models = nestedGrid()
        XCTAssertTrue(Sticky.owner(of: 0, in: models).isRoot)
        XCTAssertTrue(Sticky.owner(of: 8, in: models).isRoot)
    }

    func testNestedTitleColumnsAndRowsBelongToTheirTable() {
        let models = nestedGrid()
        for i in [1, 2, 3] {
            let owner = Sticky.owner(of: i, in: models)
            XCTAssertEqual(owner.key, 1, "row \(i)")
            XCTAssertEqual(owner.indices, [1, 2], "row \(i)")
        }
    }

    func testDeeperTableOwnsItsOwnRows() {
        let models = nestedGrid()
        for i in [4, 5, 6] {
            XCTAssertEqual(Sticky.owner(of: i, in: models).key, 4, "row \(i)")
        }
    }

    func testParentRowAfterChildTableEndsBelongsToParent() {
        XCTAssertEqual(Sticky.owner(of: 7, in: nestedGrid()).key, 1)
    }

    func testNestedBlockUsesHeaderRowWidthAndTwoRowHeight() {
        let owner = Sticky.owner(of: 3, in: nestedGrid())
        XCTAssertEqual(owner.width, 500, "width comes from the column header row, not the title row")
        XCTAssertEqual(owner.height, 2 * rowH)
    }

    func testEmptyNestedTableOwnsOnlyItsTitleAndColumns() {
        let models = emptyNestedGrid()
        XCTAssertEqual(Sticky.owner(of: 1, in: models).key, 1)
        XCTAssertEqual(Sticky.owner(of: 2, in: models).key, 1)
        XCTAssertTrue(Sticky.owner(of: 3, in: models).isRoot, "next root row is not part of the empty table")
    }

    // MARK: - owner(of:in:) out-of-sync fallback

    func testExpanderWithoutHeaderFallsBackToRoot() {
        // Rows can be out of sync mid-scroll (e.g. collapse); must not crash or pin garbage.
        let models = [row(.row(index: 0)), row(.tableExpander(level: 0))]
        XCTAssertTrue(Sticky.owner(of: 1, in: models).isRoot)
    }

    func testExpanderFollowedByNonHeaderFallsBackToRoot() {
        let models = [row(.tableExpander(level: 0)), row(.row(index: 0))]
        XCTAssertTrue(Sticky.owner(of: 0, in: models).isRoot)
    }

    func testHeaderWithoutExpanderFallsBackToRoot() {
        let models = [row(.header(level: 1, tableColumns: [], schemaKey: "d2")), row(.nestedRow(level: 1, index: 0))]
        XCTAssertTrue(Sticky.owner(of: 0, in: models).isRoot)
        XCTAssertTrue(Sticky.owner(of: 1, in: models).isRoot)
    }

    func testNestedRowWithoutHeaderAboveFallsBackToRoot() {
        let models = [row(.row(index: 0)), row(.nestedRow(level: 1, index: 0))]
        XCTAssertTrue(Sticky.owner(of: 1, in: models).isRoot)
    }

    // MARK: - placedBlocks(_:offset:)

    func testNoNextHeaderPinsCurrentAtTop() {
        let placed = Sticky.placedBlocks(layout(.root, next: nil), offset: 300)
        XCTAssertEqual(placed.count, 1)
        XCTAssertTrue(placed[0].block.isRoot)
        XCTAssertEqual(placed[0].y, 300)
    }

    func testTopMinusOneRootPinnedWhileStillInsideRealHeader() {
        // top = -1: viewport top is inside the real root header, current is root.
        let next = (block: block(key: 1), y: y(ofRow: 1))
        let offset: CGFloat = 20
        let placed = Sticky.placedBlocks(layout(.root, next: next), offset: offset)
        XCTAssertEqual(placed.count, 1, "next header is still out of reach")
        XCTAssertTrue(placed[0].block.isRoot)
        XCTAssertEqual(placed[0].y, offset)
    }

    func testNextHeaderOutOfReachDoesNotMove() {
        let next = (block: block(key: 5), y: y(ofRow: 5))
        let offset = next.y - Sticky.Block.root.height - 10
        let placed = Sticky.placedBlocks(layout(.root, next: next), offset: offset)
        XCTAssertEqual(placed.count, 1)
        XCTAssertEqual(placed[0].y, offset)
    }

    func testEnteringTablePushesCurrentUpFromBelow() {
        let next = (block: block(key: 1), y: y(ofRow: 1))
        let overlap: CGFloat = 40
        let offset = next.y - Sticky.Block.root.height + overlap
        let placed = Sticky.placedBlocks(layout(.root, next: next), offset: offset)

        XCTAssertEqual(placed.count, 2)
        XCTAssertTrue(placed[0].block.isRoot, "leaving header is the bottom layer")
        XCTAssertEqual(placed[0].y, offset - overlap, "pushed up by exactly the overlap")
        XCTAssertEqual(placed[1].block.key, 1, "arriving header draws on top")
        XCTAssertEqual(placed[1].y, next.y, "arriving header rides with its real row")
    }

    func testHandoverIsContinuousAtTheBoundary() {
        let next = (block: block(key: 1), y: y(ofRow: 1))
        let offset = next.y - Sticky.Block.root.height
        let placed = Sticky.placedBlocks(layout(.root, next: next), offset: offset)
        XCTAssertEqual(placed.first?.y, offset)
    }

    func testParentReplacesLeavingTableWhenItsRowTouchesTheHeader() {
        // Depth 3 (key 4) ends; row 7 belongs to Depth 2 (key 1), no header row starts there.
        let current = block(key: 4)
        let next = (block: block(key: 1), y: y(ofRow: 7))
        let justBefore = Sticky.placedBlocks(layout(current, next: next), offset: next.y - current.height)
        XCTAssertEqual(justBefore.map(\.block.key), [4], "row not touching yet: child still pinned")

        let offset = next.y - current.height + 1
        let placed = Sticky.placedBlocks(layout(current, next: next), offset: offset)
        XCTAssertEqual(placed.count, 1, "instant swap: the child is not drawn sliding away")
        XCTAssertEqual(placed[0].block.key, 1)
        XCTAssertEqual(placed[0].y, offset)
    }

    func testLastNestedTableEndingRevealsRoot() {
        let current = block(key: 1)
        let next = (block: Sticky.Block.root, y: y(ofRow: 8))
        let offset = next.y - current.height + 10
        let placed = Sticky.placedBlocks(layout(current, next: next), offset: offset)

        XCTAssertEqual(placed.count, 1)
        XCTAssertTrue(placed[0].block.isRoot)
        XCTAssertEqual(placed[0].y, offset)
    }

    func testEmptyNestedTableEndingRevealsRoot() {
        // Empty Depth 2 (rows 1–2) is followed directly by root row 3.
        let current = block(key: 1)
        let next = (block: Sticky.Block.root, y: y(ofRow: 3))
        let offset = next.y - current.height + 30
        let placed = Sticky.placedBlocks(layout(current, next: next), offset: offset)

        XCTAssertEqual(placed.count, 1, "root replaces the empty table")
        XCTAssertTrue(placed[0].block.isRoot)
        XCTAssertEqual(placed[0].y, offset)
    }

    // MARK: - cornerRadius(y:offset:)

    func testCornerRadiusFullWhenPinnedAtTop() {
        XCTAssertEqual(Sticky.cornerRadius(y: 300, offset: 300), maxRadius)
    }

    func testCornerRadiusFullWhileLeavingAboveTop() {
        XCTAssertEqual(Sticky.cornerRadius(y: 250, offset: 300), maxRadius)
    }

    func testCornerRadiusShrinksWhileArriving() {
        XCTAssertEqual(Sticky.cornerRadius(y: 305, offset: 300), maxRadius - 5)
    }

    func testCornerRadiusSquareWhenFarBelowTop() {
        XCTAssertEqual(Sticky.cornerRadius(y: 400, offset: 300), 0)
    }

    // MARK: - Sibling nested tables, deeper nesting

    /// One root row with two child tables, A then B:
    /// 0 root, 1 A title, 2 A columns, 3 A row, 4 B title, 5 B columns, 6 B row, 7 root
    private func siblingGrid() -> [RowDataModel] {
        [
            row(.row(index: 0)),
            row(.tableExpander(level: 0), width: 460),
            row(.header(level: 1, tableColumns: [], schemaKey: "a"), width: 500),
            row(.nestedRow(level: 1, index: 0)),
            row(.tableExpander(level: 0), width: 460),
            row(.header(level: 1, tableColumns: [], schemaKey: "b"), width: 520),
            row(.nestedRow(level: 1, index: 0)),
            row(.row(index: 1)),
        ]
    }

    /// Four levels: 0 root, 1-2 D2, 3 D2 row, 4-5 D3, 6 D3 row, 7-8 D4, 9 D4 row, 10 D3 row, 11 root
    private func fourLevelGrid() -> [RowDataModel] {
        [
            row(.row(index: 0)),
            row(.tableExpander(level: 0)), row(.header(level: 1, tableColumns: [], schemaKey: "d2"), width: 500),
            row(.nestedRow(level: 1, index: 0)),
            row(.tableExpander(level: 1)), row(.header(level: 2, tableColumns: [], schemaKey: "d3"), width: 540),
            row(.nestedRow(level: 2, index: 0)),
            row(.tableExpander(level: 2)), row(.header(level: 3, tableColumns: [], schemaKey: "d4"), width: 580),
            row(.nestedRow(level: 3, index: 0)),
            row(.nestedRow(level: 2, index: 1)),
            row(.row(index: 1)),
        ]
    }

    func testSiblingTablesEachOwnTheirRows() {
        let models = siblingGrid()
        for i in [1, 2, 3] { XCTAssertEqual(Sticky.owner(of: i, in: models).key, 1, "row \(i)") }
        for i in [4, 5, 6] { XCTAssertEqual(Sticky.owner(of: i, in: models).key, 4, "row \(i)") }
        XCTAssertEqual(Sticky.owner(of: 6, in: models).width, 520, "B uses its own header width")
    }

    func testSiblingTableStartingPushesPreviousSibling() {
        let models = siblingGrid()
        // Top row is A's row (3); the next differently-owned row is B's title at row 4.
        let current = Sticky.owner(of: 3, in: models)
        let nextOwner = Sticky.owner(of: 4, in: models)
        XCTAssertEqual(current.key, 1)
        XCTAssertEqual(nextOwner.key, 4)
        let layout = self.layout(current, next: (nextOwner, y(ofRow: 4)))
        let offset = y(ofRow: 3) + 20
        let placed = Sticky.placedBlocks(layout, offset: offset)
        XCTAssertEqual(placed.count, 2)
        XCTAssertEqual(placed[0].block.key, 1, "A is pushed out")
        XCTAssertEqual(placed[1].block.key, 4, "B arrives on top with its real row")
        XCTAssertEqual(placed[1].y, y(ofRow: 4))
    }

    func testEnteringDeeperTablePushesParent() {
        let models = nestedGrid()
        // Top row is D2 row (3); Depth 3 title at row 4 comes next.
        let current = Sticky.owner(of: 3, in: models)
        let nextOwner = Sticky.owner(of: 4, in: models)
        XCTAssertEqual(current.key, 1)
        XCTAssertEqual(nextOwner.key, 4)
        let layout = self.layout(current, next: (nextOwner, y(ofRow: 4)))
        let placed = Sticky.placedBlocks(layout, offset: y(ofRow: 3) + 10)
        XCTAssertEqual(placed.map(\.block.key), [1, 4], "Depth 2 below, Depth 3 pushing in on top")
    }

    func testFourthLevelOwnershipAndReturn() {
        let models = fourLevelGrid()
        XCTAssertEqual(Sticky.owner(of: 9, in: models).key, 7, "D4 row belongs to D4")
        XCTAssertEqual(Sticky.owner(of: 9, in: models).width, 580)
        XCTAssertEqual(Sticky.owner(of: 10, in: models).key, 4, "after D4 ends, D3 row belongs to D3")
        XCTAssertTrue(Sticky.owner(of: 11, in: models).isRoot)
        // D4 ending into D3: D3 is revealed underneath.
        let layout = self.layout(Sticky.owner(of: 9, in: models), next: (Sticky.owner(of: 10, in: models), y(ofRow: 10)))
        let placed = Sticky.placedBlocks(layout, offset: y(ofRow: 9) + 10)
        XCTAssertEqual(placed.map(\.block.key), [4], "parent D3 replaces leaving D4")
    }

    // MARK: - Composed layout(top:) + placedBlocks

    /// nestedGrid() plus extra root rows so every handoff is reachable by scrolling.
    private func scrollableNestedGrid() -> [RowDataModel] {
        nestedGrid() + (2...6).map { row(.row(index: $0)) }
    }

    private func placed(at offset: CGFloat, in models: [RowDataModel]) -> [(block: Sticky.Block, y: CGFloat)] {
        let top = min(Int((offset - Sticky.firstRowY) / rowH), models.count - 1)
        let layout = Sticky.layout(top: top, models: models, rootWidth: 600, hasNestedTables: true)
        return Sticky.placedBlocks(layout, offset: offset)
    }

    func testReturningParentWithOneRowLeftHandsOverWithoutJump() {
        // Review case: Depth 3 row at 6, one Depth 2 row at 7, root row at 8.
        let models = scrollableNestedGrid()
        let d2Touches = y(ofRow: 7) - 2 * rowH
        let rootTouches = y(ofRow: 8) - 2 * rowH
        XCTAssertEqual(placed(at: d2Touches + 1, in: models).map(\.block.key), [1], "Depth 2 row touched: Depth 2 pinned")
        XCTAssertEqual(placed(at: rootTouches + 1, in: models).map(\.block.key), [-1], "root row touched: root pinned")
        for offset in [rootTouches + 1, y(ofRow: 7) - 0.1, y(ofRow: 7), y(ofRow: 7) + 1] {
            let blocks = placed(at: offset, in: models)
            XCTAssertEqual(blocks.map(\.block.key), [-1], "offset \(offset)")
            XCTAssertEqual(blocks.first?.y, offset, "root stays pinned at the top, no jump")
        }
    }

    func testReturningParentIsPushedByTheNextTableStarting() {
        // Depth 3 ends into one Depth 2 row, then a sibling Depth 3 table starts.
        let models = [
            row(.row(index: 0)),
            row(.tableExpander(level: 0), width: 460), row(.header(level: 1, tableColumns: [], schemaKey: "d2"), width: 500),
            row(.nestedRow(level: 1, index: 0)),
            row(.tableExpander(level: 1), width: 500), row(.header(level: 2, tableColumns: [], schemaKey: "d3"), width: 540),
            row(.nestedRow(level: 2, index: 0)),
            row(.nestedRow(level: 1, index: 1)),
            row(.tableExpander(level: 1), width: 500), row(.header(level: 2, tableColumns: [], schemaKey: "d3b"), width: 540),
            row(.nestedRow(level: 2, index: 0)),
            row(.row(index: 1)),
        ]
        let offset = y(ofRow: 8) - 2 * rowH + 20
        let blocks = placed(at: offset, in: models)
        XCTAssertEqual(blocks.map(\.block.key), [1, 8], "Depth 2 pushed up, sibling Depth 3 arriving")
        XCTAssertEqual(blocks[0].y, offset - 20, "pushed by exactly the overlap")
        XCTAssertEqual(blocks[1].y, y(ofRow: 8))
    }

    func testPinnedHeadersNeverJumpWhileScrolling() {
        let step: CGFloat = 0.5
        let grids = [scrollableNestedGrid(), emptyNestedGrid() + [row(.row(index: 2))],
                     siblingGrid() + [row(.row(index: 2))], fourLevelGrid() + [row(.row(index: 2))]]
        for models in grids {
            var previous: [Int: CGFloat] = [:]
            var offset = Sticky.firstRowY
            let end = Sticky.firstRowY + CGFloat(models.count - 1) * rowH
            while offset <= end {
                let current = Dictionary(placed(at: offset, in: models).map { ($0.block.key, $0.y) }, uniquingKeysWith: { a, _ in a })
                for (key, y) in current {
                    if let prev = previous[key] {
                        XCTAssertLessThanOrEqual(abs(y - prev), step + 0.001, "block \(key) jumped at offset \(offset)")
                    }
                }
                previous = current
                offset += step
            }
        }
    }

    // MARK: - CollectionStickyScrollTracker.update

    func testTrackerIgnoresNonFiniteOffsets() {
        let tracker = CollectionStickyScrollTracker()
        tracker.update(120)
        tracker.update(.nan)
        tracker.update(.infinity)
        tracker.update(-.infinity)
        XCTAssertEqual(tracker.offsetY, 120)
    }

    func testTrackerDoesNotRepublishEqualOffset() {
        let tracker = CollectionStickyScrollTracker()
        var publishes = 0
        let sub = tracker.$offsetY.dropFirst().sink { _ in publishes += 1 }
        tracker.update(50)
        tracker.update(50)
        tracker.update(60)
        XCTAssertEqual(publishes, 2)
        sub.cancel()
    }
}
