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

    /// The same two pages, but the second is hidden. With more than one page and no
    /// logic model, `shouldShow(page:)` falls through to the page's own `hidden` flag,
    /// which is the guard `goto` rejects on.
    private func makeEditorWithHiddenSecondPage() -> DocumentEditor {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        if let index = document.files.first?.pages?.firstIndex(where: { $0.id == secondPageID }) {
            document.files[0].pages?[index].hidden = true
        }
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

    // MARK: - Threading

    /// Waits for the next write to `keyPath` and reports whether it landed on the
    /// main thread. `@Published` fires in `willSet`, so the value here is still the
    /// old one — the thread is what this is asking about.
    private func threadOfNextWrite(to publisher: Published<Bool>.Publisher,
                                   triggeredBy trigger: @escaping () -> Void) -> Bool? {
        let written = expectation(description: "the flag was written")
        var landedOnMain: Bool?

        let cancellable = publisher
            .dropFirst()            // drop the current-value replay
            .sink { _ in
                landedOnMain = Thread.isMainThread
                written.fulfill()
            }

        trigger()
        wait(for: [written], timeout: 2)
        cancellable.cancel()
        return landedOnMain
    }

    /// The `else` branch of `runOnMain`. A host calling from a background queue must
    /// not mutate published state off the main thread — SwiftUI requires the write,
    /// and the `objectWillChange` that rides with it, to happen on main.
    func testPresentPageSelectionSheet_fromBackgroundQueue_marshalsToMain() {
        let editor = makeEditor()

        let landedOnMain = threadOfNextWrite(to: editor.$showPageSelectionSheet) {
            DispatchQueue.global(qos: .userInitiated).async {
                editor.presentPageSelectionSheet(true)
            }
        }

        XCTAssertEqual(landedOnMain, true, "the write must be marshalled to the main thread")
        XCTAssertTrue(editor.showPageSelectionSheet, "and it must actually land")
    }

    func testSetPageNavigationVisible_fromBackgroundQueue_marshalsToMain() {
        let editor = makeEditor()

        let landedOnMain = threadOfNextWrite(to: editor.$showPageNavigationView) {
            DispatchQueue.global(qos: .userInitiated).async {
                editor.setPageNavigationVisible(false)
            }
        }

        XCTAssertEqual(landedOnMain, true, "the write must be marshalled to the main thread")
        XCTAssertFalse(editor.showPageNavigationView, "and it must actually land")
    }

    /// The other half of `runOnMain`, and the reason it exists rather than a plain
    /// `DispatchQueue.main.async`: on the main thread the block runs inline, so a host
    /// can read the value back on the very next line. A raw `async` would defer a
    /// runloop turn and both of these would still hold their old values.
    func testPublicMethods_onMainThread_applySynchronously() {
        let editor = makeEditor()

        editor.presentPageSelectionSheet(true)
        XCTAssertTrue(editor.showPageSelectionSheet, "must be readable immediately, not a runloop later")

        editor.setPageNavigationVisible(false)
        XCTAssertFalse(editor.showPageNavigationView, "must be readable immediately, not a runloop later")
    }

    /// Hammering the same entry point from several queues must converge rather than
    /// tear: every call funnels through the main queue, so the last write wins and
    /// nothing is lost or written concurrently.
    func testPresentPageSelectionSheet_concurrentCalls_converge() {
        let editor = makeEditor()
        let finished = expectation(description: "all calls dispatched")
        finished.expectedFulfillmentCount = 50

        DispatchQueue.concurrentPerform(iterations: 50) { _ in
            editor.presentPageSelectionSheet(true)
            DispatchQueue.main.async { finished.fulfill() }
        }

        wait(for: [finished], timeout: 5)
        XCTAssertTrue(editor.showPageSelectionSheet, "every call set it true, so it must end true")
    }

    // MARK: - Selection: the goto unwind

    /// Mirrors `PageDuplicateListView.onSelect`: it clears the internal flag directly
    /// rather than through the public method, and leaves the page change to `goto`.
    @discardableResult
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

        let status = selectPage(startingPageID, on: editor)

        XCTAssertEqual(status, .success, "the current page is always resolvable")
        XCTAssertEqual(editor.currentPageID, startingPageID, "re-selecting the current page changes nothing")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet still closes")
    }

    // MARK: - Selection with a modal open

    /// The whole reason `onSelect` calls `goto` rather than assigning `currentPageID`.
    /// With a modal open the page change is deferred: the target is parked and the
    /// modal is asked to unwind, and only once it has does the page actually move.
    /// A direct assignment would have switched the page behind the open modal.
    func testSelectingPage_whileModalIsOpen_defersUntilItUnwinds() {
        let editor = makeEditor()
        let startingPageID = editor.currentPageID
        editor.setOpenNavigationFieldID("someOpenFieldID")
        editor.presentPageSelectionSheet(true)

        selectPage(secondPageID, on: editor)

        XCTAssertEqual(editor.currentPageID, startingPageID,
                       "the page must not move while the modal is still up")
        XCTAssertEqual(editor.pendingNavigationTarget?.pageId, secondPageID,
                       "the target must be parked instead")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet still closes")

        editor.setOpenNavigationFieldID(nil)   // the modal finished dismissing

        XCTAssertEqual(editor.currentPageID, secondPageID,
                       "the page change lands once the modal has unwound")
        XCTAssertNil(editor.pendingNavigationTarget, "the parked target must be consumed")
    }

    /// `executeNavigation` defers on `openedNavigationFieldID` alone and never checks
    /// whether the page actually changed, so re-selecting the page you are already on
    /// also unwinds an open modal. A direct assignment would have left it alone.
    func testSelectingCurrentPage_whileModalIsOpen_alsoUnwindsIt() {
        let editor = makeEditor()
        let startingPageID = editor.currentPageID
        editor.setOpenNavigationFieldID("someOpenFieldID")
        editor.presentPageSelectionSheet(true)

        selectPage(startingPageID, on: editor)

        XCTAssertEqual(editor.currentPageID, startingPageID, "the page does not change")
        XCTAssertEqual(editor.pendingNavigationTarget?.pageId, startingPageID,
                       "a target is parked even though there is nothing to navigate to")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet still closes")
    }

    /// A failed `goto` must not leave the picker open in a half-dismissed state, and
    /// must not move the user anywhere. `goto` validates before it assigns, so a
    /// rejected ID never reaches `currentPageID`.
    func testFailedSelection_stillClosesSheet() {
        let editor = makeEditor()
        editor.presentPageSelectionSheet(true)
        let startingPageID = editor.currentPageID

        let status = selectPage("no-such-page-id", on: editor)

        XCTAssertEqual(editor.currentPageID, startingPageID, "the page must not change")

        XCTAssertEqual(status, .failure, "an unknown page must not resolve")
        XCTAssertNil(editor.pendingNavigationTarget, "a failed goto must not park anything")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet must not reopen on a failed goto")
    }

    /// The silent-no-op case: `goto` rejects a page hidden by conditional logic. The
    /// row list filters on `shouldShow(pageID:)`, so this is only reachable if logic
    /// re-evaluates between render and tap — but the sheet must still close cleanly
    /// rather than strand the user mid-dismissal.
    func testSelectingHiddenPage_failsButStillClosesSheet() {
        let editor = makeEditorWithHiddenSecondPage()
        XCTAssertFalse(editor.shouldShow(pageID: secondPageID), "the second page must be hidden")
        editor.presentPageSelectionSheet(true)
        let startingPageID = editor.currentPageID

        let status = selectPage(secondPageID, on: editor)

        XCTAssertEqual(status, .failure, "goto must reject a hidden page")
        XCTAssertEqual(editor.currentPageID, startingPageID,
                       "a rejected page must never land on currentPageID — it would strand the user on \"No pages available\"")
        XCTAssertNil(editor.pendingNavigationTarget, "a rejected goto must not park anything")
        XCTAssertFalse(editor.showPageSelectionSheet, "the sheet must still close")
    }

    // MARK: - Host stack

    /// Models: A (root) appears, B (pushed) appears, B presents the sheet, then an
    /// interactive swipe-back starts (A's onAppear refires) but is cancelled, so B
    /// never gets `onDisappear`. A becomes stack-top without ever asking for the sheet —
    /// `activatePageSheetHost` must close it rather than leave it orphaned on A.
    func testStackTopStolenByAnotherHost_closesTheSheet() {
        let editor = makeEditor()
        let hostA = UUID()
        let hostB = UUID()

        editor.activatePageSheetHost(hostA)          // A appears (root)
        editor.activatePageSheetHost(hostB)           // B appears (pushed) — B is top
        XCTAssertEqual(editor.pageSheetHostStack.last, hostB)

        editor.presentPageSelectionSheet(true)        // user opens picker from B
        XCTAssertTrue(editor.showPageSelectionSheet)

        // Interactive swipe-back begins and is cancelled: A's onAppear fires again,
        // but B's onDisappear never does (B never actually left the screen).
        editor.activatePageSheetHost(hostA)

        XCTAssertEqual(editor.pageSheetHostStack.last, hostA,
                       "A is now top, even though B is still what's on screen")
        XCTAssertFalse(editor.showPageSelectionSheet,
                       "a host taking over top without the previous one deactivating must close the sheet, " +
                       "not hand it to a host that never asked for it")
    }

    /// Continuation: because the steal above already closes the sheet, a third host that
    /// later becomes top must not inherit anything — no auto-present with no tap.
    func testStackTopStolenByAnotherHost_laterHostDoesNotInheritTheSheet() {
        let editor = makeEditor()
        let hostA = UUID()
        let hostB = UUID()
        let hostC = UUID()

        editor.activatePageSheetHost(hostA)
        editor.activatePageSheetHost(hostB)
        editor.presentPageSelectionSheet(true)
        editor.activatePageSheetHost(hostA)           // cancelled swipe-back, as above — B never deactivates

        // Time passes; user navigates to a totally unrelated host C (e.g. opens a chart detail).
        editor.activatePageSheetHost(hostC)

        XCTAssertEqual(editor.pageSheetHostStack.last, hostC)
        XCTAssertFalse(editor.showPageSelectionSheet,
                       "the sheet was already closed when A stole the top — C must not auto-present it")
    }

    /// The documented, intentional counterpart: when the top host deactivates cleanly
    /// (a real `onDisappear`, not a steal), the sheet must carry over to whatever host
    /// is left on top — this is `deactivatePageSheetHost`'s "regains automatically" contract.
    func testHostDeactivating_handsTheOpenSheetToNewTop() {
        let editor = makeEditor()
        let hostA = UUID()
        let hostB = UUID()

        editor.activatePageSheetHost(hostA)
        editor.activatePageSheetHost(hostB)
        editor.presentPageSelectionSheet(true)

        editor.deactivatePageSheetHost(hostB)          // B properly pops — real onDisappear

        XCTAssertEqual(editor.pageSheetHostStack.last, hostA)
        XCTAssertTrue(editor.showPageSelectionSheet,
                      "a clean hand-off must still let the revealed host regain the open sheet")
    }

    /// Re-activating the host that is already on top (e.g. a spurious duplicate `onAppear`)
    /// must not be treated as a steal and must not close an open sheet.
    func testReactivatingTheCurrentTopHost_doesNotCloseTheSheet() {
        let editor = makeEditor()
        let hostA = UUID()

        editor.activatePageSheetHost(hostA)
        editor.presentPageSelectionSheet(true)

        editor.activatePageSheetHost(hostA)            // duplicate onAppear for the same host

        XCTAssertTrue(editor.showPageSelectionSheet, "re-activating the current top host must not close its own sheet")
    }

    // MARK: - Host stack: publish-on-write-only

    /// `pageSheetHostStack` is plain storage now, not `@Published` — every push/pop must stop
    /// re-rendering hosts on its own. The only allowed emission is `showPageSelectionSheet`'s own,
    /// which fires here because the steal closes it.
    func testStackTopStolen_emitsOnlyForTheSheetClosing() {
        let editor = makeEditor()
        let hostA = UUID()
        let hostB = UUID()
        editor.activatePageSheetHost(hostA)
        editor.activatePageSheetHost(hostB)
        editor.presentPageSelectionSheet(true)

        let emissions = countEmissions(on: editor) {
            editor.activatePageSheetHost(hostA)
        }

        XCTAssertEqual(emissions, 1, "only showPageSelectionSheet's own publish should fire, not one from the stack mutation")
    }

    /// Ordinary forward navigation with no sheet open: pushing/popping hosts must be silent.
    func testHostStackChangesWhileSheetClosed_emitNothing() {
        let editor = makeEditor()
        let hostA = UUID()
        let hostB = UUID()

        let emissions = countEmissions(on: editor) {
            editor.activatePageSheetHost(hostA)
            editor.activatePageSheetHost(hostB)
            editor.deactivatePageSheetHost(hostB)
            editor.deactivatePageSheetHost(hostA)
        }

        XCTAssertEqual(emissions, 0, "with the sheet closed, no host needs to know the stack changed")
    }

    /// Re-activating the current top host is a no-op for the stack: must not publish.
    func testReactivatingCurrentTopHost_emitsNothing() {
        let editor = makeEditor()
        let hostA = UUID()
        editor.activatePageSheetHost(hostA)
        editor.presentPageSelectionSheet(true)

        let emissions = countEmissions(on: editor) {
            editor.activatePageSheetHost(hostA)
        }

        XCTAssertEqual(emissions, 0, "re-activating the host that's already on top changes nothing observable")
    }

    /// The one case `deactivatePageSheetHost` is meant to publish for: a clean hand-off while
    /// the sheet is open, so the revealed host's `isPresented` binding re-evaluates.
    func testCleanHandoffWhileSheetOpen_emitsExactlyOnce() {
        let editor = makeEditor()
        let hostA = UUID()
        let hostB = UUID()
        editor.activatePageSheetHost(hostA)
        editor.activatePageSheetHost(hostB)
        editor.presentPageSelectionSheet(true)

        let emissions = countEmissions(on: editor) {
            editor.deactivatePageSheetHost(hostB)
        }

        XCTAssertEqual(emissions, 1, "the revealed host needs exactly one publish to pick up the handed-off sheet")
    }
}
