//
//  DecoratorCOWTests.swift
//  JoyfillTests
//
//  Copy-on-write seeding: the first write to a "specific" scope (row-self, cell,
//  row-scoped column) seeds from the matching "common" scope so the specific
//  write diverges without dropping previously-inherited decorators.
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class DecoratorCOWTests: XCTestCase {

    // MARK: - rowSelf seeds from commonRows

    func testRowSelf_firstWrite_seedsFromCommonRows_table() {
        let (editor, _) = makeChangerHandlerEditor()
        let commonPath = ChangerHandlerSample.tableCommonRowsPath()
        let selfPath   = ChangerHandlerSample.tableRowSelfPath()

        // Seed common with two decorators
        editor.addDecorators(path: commonPath, decorators: [
            makeDecorator(action: "common1"),
            makeDecorator(action: "common2"),
        ])

        // First row-self write: new decorator should be appended AFTER the common-seeded ones
        editor.addDecorators(path: selfPath, decorators: [makeDecorator(action: "specific")])

        let read = editor.getDecorators(path: selfPath)
        XCTAssertEqual(read.map { $0.action }, ["common1", "common2", "specific"],
                       "row-self should seed from common rows on first write")
    }

    func testRowSelf_firstWrite_seedsFromCommonRows_collectionRoot() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "rootCommon")])
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "rootSelf")])
        let read = editor.getDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath())
        XCTAssertEqual(read.map { $0.action }, ["rootCommon", "rootSelf"])
    }

    func testRowSelf_firstWrite_seedsFromCommonRows_collectionNested() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "nCommon")])
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowSelfPath(),
                             decorators: [makeDecorator(action: "nSelf")])
        let read = editor.getDecorators(path: ChangerHandlerSample.collectionNestedRowSelfPath())
        XCTAssertEqual(read.map { $0.action }, ["nCommon", "nSelf"])
    }

    // MARK: - cell seeds from commonColumn

    func testCell_firstWrite_seedsFromCommonColumn_table() {
        let (editor, _) = makeChangerHandlerEditor()
        let commonPath = ChangerHandlerSample.tableCommonColumnPath()
        let cellPath   = ChangerHandlerSample.tableCellPath()

        editor.addDecorators(path: commonPath, decorators: [
            makeDecorator(action: "colCommon1"),
            makeDecorator(action: "colCommon2"),
        ])
        editor.addDecorators(path: cellPath, decorators: [makeDecorator(action: "cellOverride")])

        let read = editor.getDecorators(path: cellPath)
        XCTAssertEqual(read.map { $0.action }, ["colCommon1", "colCommon2", "cellOverride"],
                       "cell should seed from common column on first write")
    }

    func testCell_firstWrite_seedsFromCommonColumn_collectionNested() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonColumnPath(),
                             decorators: [makeDecorator(action: "nColCommon")])
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCellPath(),
                             decorators: [makeDecorator(action: "nCell")])
        let read = editor.getDecorators(path: ChangerHandlerSample.collectionNestedCellPath())
        XCTAssertEqual(read.map { $0.action }, ["nColCommon", "nCell"])
    }

    // MARK: - COW is one-shot (subsequent common changes don't auto-propagate)

    func testRowSelf_subsequentCommonChange_doesNotAffectSpecific() {
        let (editor, _) = makeChangerHandlerEditor()
        let commonPath = ChangerHandlerSample.tableCommonRowsPath()
        let selfPath   = ChangerHandlerSample.tableRowSelfPath()

        editor.addDecorators(path: commonPath, decorators: [makeDecorator(action: "common1")])
        editor.addDecorators(path: selfPath,   decorators: [makeDecorator(action: "specific")])
        // At this point selfPath = [common1, specific]

        // Change the common slot
        editor.addDecorators(path: commonPath, decorators: [makeDecorator(action: "common2")])

        let selfRead = editor.getDecorators(path: selfPath)
        XCTAssertEqual(selfRead.map { $0.action }, ["common1", "specific"],
                       "specific scope must not auto-pick up later changes to common")
        let commonRead = editor.getDecorators(path: commonPath)
        XCTAssertEqual(commonRead.map { $0.action }, ["common1", "common2"])
    }

    // MARK: - No seed when common is empty

    func testRowSelf_commonEmpty_firstWriteContainsOnlySpecific() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "loneSelf")])
        XCTAssertEqual(editor.getDecorators(path: ChangerHandlerSample.tableRowSelfPath()).map { $0.action },
                       ["loneSelf"])
    }

    func testCell_commonEmpty_firstWriteContainsOnlyCell() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "loneCell")])
        XCTAssertEqual(editor.getDecorators(path: ChangerHandlerSample.tableCellPath()).map { $0.action },
                       ["loneCell"])
    }

    // MARK: - No seed on second write (specific is already non-empty)

    func testRowSelf_secondWrite_noReSeed() {
        let (editor, _) = makeChangerHandlerEditor()
        let commonPath = ChangerHandlerSample.tableCommonRowsPath()
        let selfPath   = ChangerHandlerSample.tableRowSelfPath()

        editor.addDecorators(path: commonPath, decorators: [makeDecorator(action: "common1")])
        editor.addDecorators(path: selfPath,   decorators: [makeDecorator(action: "self1")])
        // selfPath = [common1, self1]
        editor.addDecorators(path: selfPath,   decorators: [makeDecorator(action: "self2")])

        let read = editor.getDecorators(path: selfPath)
        XCTAssertEqual(read.map { $0.action }, ["common1", "self1", "self2"],
                       "second write to row-self must append, not re-seed from common")
    }
}
