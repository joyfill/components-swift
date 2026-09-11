//
//  PageSelectionSheetTests.swift
//  JoyfillTests
//
//  Unit coverage for the public `presentPageSelectionSheet(_:)` API: the
//  host-facing contract, the `@Published` guarantee the sheet anchor relies
//  on, and the `goto` unwind on selection.
//
//  `showPageSelectionSheet` is internal — these tests reach it via
//  `@testable` to assert state, but drive it through the public method.
//
//  Not coverable here (needs a UI test / manual pass): that a sheet actually
//  presents.
//

import XCTest
import Combine
import JoyfillModel
@testable import Joyfill

final class PageSelectionSheetTests: XCTestCase {

    private let firstPageID = "6629fab320fca7c8107a6cf6"
    private let secondPageID = "second_page_id_12345"

    // MARK: - Helpers

    /// Two visible pages, so `goto` has a real target to move to.
    private func makeEditor() -> DocumentEditor {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        return DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
    }

    private func countEmissions(on editor: DocumentEditor,
                                during body: () -> Void) -> Int {
        var emissions = 0
        let cancellable = editor.objectWillChange.sink { _ in emissions += 1 }
        body()
        _ = cancellable
        return emissions
    }

    // MARK: - Defaults

    func testShowPageSelectionSheet_defaultsToFalse() {
        let editor = makeEditor()

        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet must start closed")
    }

    /// The schema-error path returns early from `init`, so the flag must still
    /// be usable rather than left in some half-configured state.
    func testShowPageSelectionSheet_defaultsToFalseOnSchemaError() {
        let invalid = JoyDoc(dictionary: ["identifier": "test-doc", "name": "Invalid Doc"])
        let editor = DocumentEditor(document: invalid, config: DocumentEditorConfig(validateSchema: true))

        XCTAssertNotNil(editor.schemaError, "this document is expected to fail validation")
        XCTAssertFalse(editor.showPageSelectionSheet, "flag must default false even on the early-return path")

        editor.presentPageSelectionSheet(true)
        XCTAssertTrue(editor.showPageSelectionSheet, "a host must still be able to set the flag")
    }

    // MARK: - The public method

    func testPresentPageSelectionSheet_opensAndCloses() {
        let editor = makeEditor()

        editor.presentPageSelectionSheet(true)
        XCTAssertTrue(editor.showPageSelectionSheet, "passing true must open the sheet")

        editor.presentPageSelectionSheet(false)
        XCTAssertFalse(editor.showPageSelectionSheet, "passing false must close it")
    }

    func testSetPageNavigationVisible_showsAndHides() {
        let editor = makeEditor()

        editor.setPageNavigationVisible(false)
        XCTAssertFalse(editor.showPageNavigationView, "passing false must hide the nav button")

        editor.setPageNavigationVisible(true)
        XCTAssertTrue(editor.showPageNavigationView, "passing true must show it again")
    }

    /// Calling it with the value it already holds must stay a plain write, so a
    /// host can call it unconditionally without special-casing current state.
    func testPresentPageSelectionSheet_isIdempotent() {
        let editor = makeEditor()

        editor.presentPageSelectionSheet(true)
        editor.presentPageSelectionSheet(true)
        XCTAssertTrue(editor.showPageSelectionSheet)

        editor.presentPageSelectionSheet(false)
        editor.presentPageSelectionSheet(false)
        XCTAssertFalse(editor.showPageSelectionSheet)
    }

    // MARK: - Independence from the built-in navigation button

    /// The whole point of the API: a host hides the built-in button and drives
    /// the picker itself, so the two flags must not be coupled in either direction.
    func testShowPageSelectionSheet_worksWhileNavigationButtonHidden() {
        let editor = makeEditor()

        editor.setPageNavigationVisible(false)
        editor.presentPageSelectionSheet(true)

        XCTAssertFalse(editor.showPageNavigationView, "button stays hidden")
        XCTAssertTrue(editor.showPageSelectionSheet, "hiding the button must not block the sheet")
    }

    func testShowPageNavigationView_isNotChangedBySheetFlag() {
        let editor = makeEditor()
        let original = editor.showPageNavigationView

        editor.presentPageSelectionSheet(true)
        XCTAssertEqual(editor.showPageNavigationView, original, "opening the sheet must not touch the button")

        editor.presentPageSelectionSheet(false)
        XCTAssertEqual(editor.showPageNavigationView, original, "closing the sheet must not touch the button")
    }

    /// `PageConfig.navigation` must land on the button flag only.
    func testPageConfigNavigation_doesNotDriveTheSheetFlag() {
        let config = DocumentEditorConfig(validateSchema: false,
                                          page: PageConfig(navigation: false))
        let editor = DocumentEditor(document: JoyDoc(), config: config)

        XCTAssertFalse(editor.showPageNavigationView, "config.page.navigation maps here")
        XCTAssertFalse(editor.showPageSelectionSheet, "config must not open the sheet as a side effect")
    }

    /// The footer example toggles this flag; it must survive a round trip.
    func testSetPageNavigationVisible_toggleRoundTrip() {
        let editor = makeEditor()
        XCTAssertTrue(editor.showPageNavigationView, "default is visible")

        editor.setPageNavigationVisible(!editor.showPageNavigationView)
        XCTAssertFalse(editor.showPageNavigationView)

        editor.setPageNavigationVisible(!editor.showPageNavigationView)
        XCTAssertTrue(editor.showPageNavigationView, "toggling twice returns to the original state")
    }

    // MARK: - @Published contract

    /// Load-bearing: the flag is the *only* published trigger that makes both
    /// anchors re-evaluate. If it stops publishing, the sheet never presents.
    func testShowPageSelectionSheet_publishesOnEveryChange() {
        let editor = makeEditor()

        let emissions = countEmissions(on: editor) {
            editor.presentPageSelectionSheet(true)
            editor.presentPageSelectionSheet(false)
        }

        XCTAssertEqual(emissions, 2, "each presentPageSelectionSheet(_:) call must publish")
    }

    /// Regression guard: this was a plain `var` before the sheet work. As a
    /// plain `var`, hiding the button from a host leaves it on screen.
    func testShowPageNavigationView_publishesOnEveryChange() {
        let editor = makeEditor()

        let emissions = countEmissions(on: editor) {
            editor.setPageNavigationVisible(false)
            editor.setPageNavigationVisible(true)
        }

        XCTAssertEqual(emissions, 2, "showPageNavigationView must stay @Published")
    }

    // MARK: - Selection: the goto unwind

    /// Mirrors `PageDuplicateListView`'s `onSelect` at `FormView.swift:482-484`, which
    /// assigns the internal flag directly rather than going through the public method.
    private func selectPage(_ pageID: String, on editor: DocumentEditor) -> NavigationStatus {
        editor.showPageSelectionSheet = false
        return editor.goto(pageID)
    }

    func testSelectingPage_changesPageAndClosesSheet() {
        let editor = makeEditor()
        editor.presentPageSelectionSheet(true)

        let status = selectPage(secondPageID, on: editor)

        XCTAssertEqual(status, .success, "a visible page must be reachable")
        XCTAssertEqual(editor.currentPageID, secondPageID, "the page must actually change")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet must close on selection")
    }

    func testSelectingCurrentPage_isANoOpButStillCloses() {
        let editor = makeEditor()
        let startingPageID = editor.currentPageID
        editor.presentPageSelectionSheet(true)

        _ = selectPage(startingPageID, on: editor)

        XCTAssertEqual(editor.currentPageID, startingPageID, "re-selecting the current page changes nothing")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet still closes")
    }

    /// A failed `goto` must not leave the picker open in a half-dismissed state.
    func testFailedSelection_stillClosesSheet() {
        let editor = makeEditor()
        editor.presentPageSelectionSheet(true)
        let startingPageID = editor.currentPageID

        let status = selectPage("no-such-page-id", on: editor)

        XCTAssertEqual(status, .failure, "an unknown page must not resolve")
        XCTAssertEqual(editor.currentPageID, startingPageID, "the page must not change")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet must not reopen on a failed goto")
    }
}
