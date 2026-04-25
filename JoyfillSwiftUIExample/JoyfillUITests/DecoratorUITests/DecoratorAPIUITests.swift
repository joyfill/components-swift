import XCTest

// MARK: - Shared IDs (from Decorator.json)

private let pageID = "69709dc281b4c8ab68c4db52"

// Table field position and rows
private let fpTable  = "69709462236416126c166efe"
private let tableRow1 = "697090a399394f50229899a9"
private let tColText  = "697090a35fe3eb39f20fa2d8"

// Collection field position and root rows
private let fpCollection = "6970a3eceab9374076e43a0b"
private let collRootRow1 = "6970a40230cef1a03fc19d81"
private let collRootRow2 = "69e9b8309d0510fadb7357c4"
private let collRootRow3 = "69e9b831f5d8f86b5ba20088"
private let cColText     = "697090a3e627059c068c4858"

// Level-1 schema and rows (under collRootRow2)
private let schemaL1          = "level1Table1"
private let l1Row1UnderRoot2  = "69e9b83351a2532dfd602819"
private let cL1ColMultiSelect = "69e88266152a89811c37dc7f"

// Level-2 schema and rows (under collRootRow3 / l1Row1UnderRoot3)
private let schemaL2         = "level2Table1"
private let l1Row1UnderRoot3 = "69e9b835b226373e47bf8f30"
private let l2Row1           = "69e9b8384eb45bbdf1de3d97"
private let cL2ColBarcode    = "69e8827e72fb2149cfd944a4"

// Text field
private let fpTextField = "6970918d350238d0738dd5c9"

// MARK: - Decorator base (disables animations for all decorator tests)

class DecoratorAPIUITestsBase: JoyfillUITestsBaseClass {
    override func getGotoLaunchArguments() -> [(String, String?)] {
        return [("--disable-animations", nil)]
    }
}

// MARK: - Text Field

final class DecoratorTextFieldAPIUITests: DecoratorAPIUITestsBase {

    override func getJSONFileNameForTest() -> String { "Decorator" }

    private var fieldPath: String { "\(pageID)/\(fpTextField)" }

    func testDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]

        S.run(S.addCommand(path: fieldPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        XCTAssertEqual(flag.label, "Flag")

        S.run(S.updateCommand(path: fieldPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { flag.label == "Done" })

        flag.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpTextField)

        S.run(S.removeCommand(path: fieldPath, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists })
    }
}

// MARK: - Table (Common Row / Specific Row / Cell)

final class DecoratorTableAPIUITests: DecoratorAPIUITestsBase {

    override func getJSONFileNameForTest() -> String { "Decorator" }

    private var rowsPath:         String { "\(pageID)/\(fpTable)/rows" }
    private var row1Path:         String { "\(pageID)/\(fpTable)/\(tableRow1)" }
    private var cell1Path:        String { "\(pageID)/\(fpTable)/\(tableRow1)/\(tColText)" }
    private var commonCell1Path:  String { "\(pageID)/\(fpTable)/columns/\(tColText)" }

    // Common row: decorator appears on every row
    func testCommonRowDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openTableDetailView(in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: rowsPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: rowsPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpTable)

        S.run(S.removeCommand(path: rowsPath, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // Specific row: decorator appears only on the targeted row
    func testSpecificRowDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openTableDetailView(in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: row1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: row1Path, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpTable)

        S.run(S.removeCommand(path: row1Path, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // COW: add common first, then specific → kebab appears → verify popover → update → tap → remove
    func testCOWSpecificRowKebabLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openTableDetailView(in: app)

        let kebab   = app.buttons[S.rowDecoratorMenuID]
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        // add common flag → all rows show flag button
        S.run(S.addCommand(path: rowsPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1),
                      "Common flag should appear on every row")

        // add comment to row 1 → COW seeds [flag + comment] → kebab appears on row 1
        S.run(S.addCommand(path: row1Path,
                           decorators: [S.decorator(action: "comment", icon: "comment", label: "Comment")]),
              in: app)
        XCTAssertTrue(kebab.waitForExistence(timeout: 1),
                      "Row 1 should show kebab after COW seeding")

        // tap kebab → popover lists both decorators
        kebab.tap()
        XCTAssertTrue(app.buttons["Flag"].waitForExistence(timeout: 1),
                      "Popover should show Flag decorator")
        XCTAssertTrue(app.buttons["Comment"].exists,
                      "Popover should show Comment decorator")

        // update comment on row 1 → label changes in popover
        S.run(S.updateCommand(path: row1Path, action: "comment",
                              decorator: S.decorator(action: "comment", icon: "comment", label: "Reviewed")),
              in: app)
        XCTAssertTrue(kebab.waitForExistence(timeout: 1))
        kebab.tap()
        XCTAssertTrue(app.buttons["Reviewed"].waitForExistence(timeout: 1),
                      "Popover should show updated label 'Reviewed'")

        // tap 'Reviewed' → onFocus fires for comment action
        app.buttons["Reviewed"].tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "comment", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "comment", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "comment")
        XCTAssertEqual(fe["target"] as? String, "comment")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpTable)

        // remove comment from row 1 → kebab disappears, single flag button returns
        S.run(S.removeCommand(path: row1Path, action: "comment"), in: app)
        XCTAssertTrue(waitUntil(2) { !kebab.exists },
                      "Kebab should disappear after removing the specific decorator")
        XCTAssertTrue(app.buttons[S.rowDecoratorID(action: "flag")].waitForExistence(timeout: 1),
                      "Row 1 should show single flag button again")
    }

    // Cell COW: flag at common cell scope (all rows, text column) → flag shows in every row's edit form
    // then comment at specific cell (row 1, text column) → COW seeds row 1's cell with [flag + comment]
    // navigate to row 2 → only flag (comment is row-1-specific) → back to row 1 → update → tap → remove
    func testCOWSpecificCellLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openTableDetailView(in: app)

        let flagButton    = app.buttons[S.fieldDecoratorID(action: "flag")]
        let commentButton = app.buttons[S.fieldDecoratorID(action: "comment")]

        // add flag at common cell scope → text column shows flag in ALL rows' edit forms
        S.run(S.addCommand(path: commonCell1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should appear in row 1 edit form")

        // navigate to row 2 → flag also present (it's common across all rows for this column)
        S.navigateToNextRowInEditForm(in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should appear in row 2 edit form too")
        S.navigateToPreviousRowInEditForm(in: app)
        S.dismissRowEditForm(in: app)

        // add comment at specific cell (row 1, text column) → COW seeds [flag + comment] on row 1's cell
        S.run(S.addCommand(path: cell1Path,
                           decorators: [S.decorator(action: "comment", icon: "comment", label: "Comment")]),
              in: app)

        // open row 1 edit form → both flag and comment present
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1))
        XCTAssertTrue(commentButton.exists, "Comment button should appear alongside flag in row 1")
        XCTAssertEqual(commentButton.label, "Comment")

        // navigate to row 2 → only flag (comment is specific to row 1's cell)
        S.navigateToNextRowInEditForm(in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should still appear in row 2")
        XCTAssertTrue(waitUntil(2) { !commentButton.exists },
                      "Comment should not appear in row 2 — it is cell-specific to row 1")

        // navigate back to row 1 → both reappear
        S.navigateToPreviousRowInEditForm(in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1))
        XCTAssertTrue(commentButton.exists)
        S.dismissRowEditForm(in: app)

        // update comment → open form → verify label changed
        S.run(S.updateCommand(path: cell1Path, action: "comment",
                              decorator: S.decorator(action: "comment", icon: "comment", label: "Reviewed")),
              in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(waitUntil(2) { commentButton.label == "Reviewed" })

        // tap comment → onFocus fires
        XCTAssertTrue(commentButton.waitForExistence(timeout: 1))
        commentButton.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "comment", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "comment", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "comment")
        XCTAssertEqual(fe["target"] as? String, "comment")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpTable)
        S.dismissRowEditForm(in: app)

        // remove comment → open form → only flag remains
        S.run(S.removeCommand(path: cell1Path, action: "comment"), in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should still be present")
        XCTAssertTrue(waitUntil(2) { !commentButton.exists },
                      "Comment button should be gone after remove")
        S.dismissRowEditForm(in: app)
    }

    // Cell: decorator appears inside the row edit form
    func testCellDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openTableDetailView(in: app)
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]

        S.run(S.addCommand(path: cell1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        XCTAssertEqual(flag.label, "Flag")

        // navigate to row 2 → decorator must be absent (cell-specific to row 1)
        S.navigateToNextRowInEditForm(in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists },
                      "Flag should not appear in row 2 — it is cell-specific to row 1")
        S.navigateToPreviousRowInEditForm(in: app)
        S.dismissRowEditForm(in: app)

        S.run(S.updateCommand(path: cell1Path, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(waitUntil(2) { flag.label == "Done" })

        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        flag.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpTable)
        S.dismissRowEditForm(in: app)

        S.run(S.removeCommand(path: cell1Path, action: "flag"), in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists })
        S.dismissRowEditForm(in: app)
    }
}

// MARK: - Collection (Root Common / Root Specific / Root Cell / Nested L1 & L2 / Nested Cell L1 & L2)

final class DecoratorCollectionAPIUITests: DecoratorAPIUITestsBase {

    override func getJSONFileNameForTest() -> String { "Decorator" }

    private var rootRowsPath:       String { "\(pageID)/\(fpCollection)/rows" }
    private var rootRow1Path:       String { "\(pageID)/\(fpCollection)/\(collRootRow1)" }
    private var rootCell1Path:      String { "\(pageID)/\(fpCollection)/\(collRootRow1)/\(cColText)" }
    private var commonRootCell1Path: String { "\(pageID)/\(fpCollection)/columns/\(cColText)" }

    private var l1RowsPath: String {
        "\(pageID)/\(fpCollection)/\(collRootRow2)/schemas/\(schemaL1)/rows"
    }
    private var l1Row1Path: String {
        "\(pageID)/\(fpCollection)/\(collRootRow2)/schemas/\(schemaL1)/\(l1Row1UnderRoot2)"
    }
    private var l2Row1Path: String {
        "\(pageID)/\(fpCollection)/\(collRootRow3)/schemas/\(schemaL1)/\(l1Row1UnderRoot3)/schemas/\(schemaL2)/\(l2Row1)"
    }
    private var l1CellPath: String {
        "\(pageID)/\(fpCollection)/\(collRootRow2)/schemas/\(schemaL1)/\(l1Row1UnderRoot2)/\(cL1ColMultiSelect)"
    }
    private var l2CellPath: String {
        "\(pageID)/\(fpCollection)/\(collRootRow3)/schemas/\(schemaL1)/\(l1Row1UnderRoot3)/schemas/\(schemaL2)/\(l2Row1)/\(cL2ColBarcode)"
    }

    // Common root row: decorator appears on every root row
    func testCommonRootRowDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: rootRowsPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: rootRowsPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)

        S.run(S.removeCommand(path: rootRowsPath, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // Specific root row: decorator appears only on the targeted root row
    func testSpecificRootRowDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: rootRow1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: rootRow1Path, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)

        S.run(S.removeCommand(path: rootRow1Path, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // COW: add common first, then specific → kebab appears → verify popover → update → tap → remove
    func testCOWSpecificRootRowKebabLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)

        let kebab    = app.buttons[S.rowDecoratorMenuID]
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        // add common flag → all root rows show flag button
        S.run(S.addCommand(path: rootRowsPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1),
                      "Common flag should appear on every root row")

        // add comment to root row 1 → COW seeds [flag + comment] → kebab appears on root row 1
        S.run(S.addCommand(path: rootRow1Path,
                           decorators: [S.decorator(action: "comment", icon: "comment", label: "Comment")]),
              in: app)
        XCTAssertTrue(kebab.waitForExistence(timeout: 1),
                      "Root row 1 should show kebab after COW seeding")

        // tap kebab → popover lists both decorators
        kebab.tap()
        XCTAssertTrue(app.buttons["Flag"].waitForExistence(timeout: 1),
                      "Popover should show Flag decorator")
        XCTAssertTrue(app.buttons["Comment"].exists,
                      "Popover should show Comment decorator")

        // update comment on root row 1 → label changes in popover
        S.run(S.updateCommand(path: rootRow1Path, action: "comment",
                              decorator: S.decorator(action: "comment", icon: "comment", label: "Reviewed")),
              in: app)
        XCTAssertTrue(kebab.waitForExistence(timeout: 1))
        kebab.tap()
        XCTAssertTrue(app.buttons["Reviewed"].waitForExistence(timeout: 1),
                      "Popover should show updated label 'Reviewed'")

        // tap 'Reviewed' → onFocus fires for comment action
        app.buttons["Reviewed"].tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "comment", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "comment", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "comment")
        XCTAssertEqual(fe["target"] as? String, "comment")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)

        // remove comment from root row 1 → kebab disappears, single flag button returns
        S.run(S.removeCommand(path: rootRow1Path, action: "comment"), in: app)
        XCTAssertTrue(waitUntil(2) { !kebab.exists },
                      "Kebab should disappear after removing the specific decorator")
        XCTAssertTrue(app.buttons[S.rowDecoratorID(action: "flag")].waitForExistence(timeout: 1),
                      "Root row 1 should show single flag button again")
    }

    // Root cell COW: flag at common cell scope (all rows, text column) → flag shows in every row's edit form
    // then comment at specific cell (root row 1, text column) → COW seeds [flag + comment] on row 1's cell
    // navigate to row 2 → only flag (comment is root-row-1-specific) → back to row 1 → update → tap → remove
    func testCOWSpecificRootCellLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)

        let flagButton    = app.buttons[S.fieldDecoratorID(action: "flag")]
        let commentButton = app.buttons[S.fieldDecoratorID(action: "comment")]

        // add flag at common cell scope → text column shows flag in ALL root rows' edit forms
        S.run(S.addCommand(path: commonRootCell1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should appear in root row 1 edit form")

        // navigate to root row 2 → flag also present (common across all rows for this column)
        S.navigateToNextRowInEditForm(in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should appear in root row 2 edit form too")
        S.navigateToPreviousRowInEditForm(in: app)
        S.dismissRowEditForm(in: app)

        // add comment at specific cell (root row 1, text column) → COW seeds [flag + comment]
        S.run(S.addCommand(path: rootCell1Path,
                           decorators: [S.decorator(action: "comment", icon: "comment", label: "Comment")]),
              in: app)

        // open root row 1 edit form → both flag and comment present
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1))
        XCTAssertTrue(commentButton.exists, "Comment button should appear alongside flag in root row 1")
        XCTAssertEqual(commentButton.label, "Comment")

        // navigate to root row 2 → only flag (comment is specific to root row 1's cell)
        S.navigateToNextRowInEditForm(in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should still appear in root row 2")
        XCTAssertTrue(waitUntil(2) { !commentButton.exists },
                      "Comment should not appear in root row 2 — it is cell-specific to root row 1")

        // navigate back to root row 1 → both reappear
        S.navigateToPreviousRowInEditForm(in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1))
        XCTAssertTrue(commentButton.exists)
        S.dismissRowEditForm(in: app)

        // update comment → open form → verify label changed
        S.run(S.updateCommand(path: rootCell1Path, action: "comment",
                              decorator: S.decorator(action: "comment", icon: "comment", label: "Reviewed")),
              in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(waitUntil(2) { commentButton.label == "Reviewed" })

        // tap comment → onFocus fires
        XCTAssertTrue(commentButton.waitForExistence(timeout: 1))
        commentButton.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "comment", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "comment", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "comment")
        XCTAssertEqual(fe["target"] as? String, "comment")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)
        S.dismissRowEditForm(in: app)

        // remove comment → open form → only flag remains
        S.run(S.removeCommand(path: rootCell1Path, action: "comment"), in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flagButton.waitForExistence(timeout: 1),
                      "Common cell flag should still be present")
        XCTAssertTrue(waitUntil(2) { !commentButton.exists },
                      "Comment button should be gone after remove")
        S.dismissRowEditForm(in: app)
    }

    // Root cell: decorator appears inside the root row edit form
    func testRootCellDecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]

        S.run(S.addCommand(path: rootCell1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        XCTAssertEqual(flag.label, "Flag")

        // navigate to root row 2 → decorator must be absent (cell-specific to root row 1)
        S.navigateToNextRowInEditForm(in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists },
                      "Flag should not appear in root row 2 — it is cell-specific to root row 1")
        S.navigateToPreviousRowInEditForm(in: app)
        S.dismissRowEditForm(in: app)

        S.run(S.updateCommand(path: rootCell1Path, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(waitUntil(2) { flag.label == "Done" })
        S.dismissRowEditForm(in: app)

        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        flag.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)
        S.dismissRowEditForm(in: app)

        S.run(S.removeCommand(path: rootCell1Path, action: "flag"), in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists })
        S.dismissRowEditForm(in: app)
    }

    // Nested common row (L1): decorator appears on all L1 rows under root row 2
    func testNestedCommonRowLevel1DecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 2, in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: l1RowsPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: l1RowsPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)

        S.run(S.removeCommand(path: l1RowsPath, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // Nested specific row (L1): decorator appears only on targeted L1 row
    func testNestedSpecificRowLevel1DecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 2, in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: l1Row1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: l1Row1Path, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)

        S.run(S.removeCommand(path: l1Row1Path, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // Nested specific row (L2): decorator appears only on targeted L2 row
    func testNestedSpecificRowLevel2DecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 3, in: app)
        S.expandCollectionNestedRow(at: 1, in: app)
        let allFlags = { self.app.buttons.matching(identifier: S.rowDecoratorID(action: "flag")) }

        S.run(S.addCommand(path: l2Row1Path,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(allFlags().element(boundBy: 0).waitForExistence(timeout: 1))
        XCTAssertEqual(allFlags().element(boundBy: 0).label, "Flag")

        S.run(S.updateCommand(path: l2Row1Path, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().element(boundBy: 0).label == "Done" })

        allFlags().element(boundBy: 0).tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)

        S.run(S.removeCommand(path: l2Row1Path, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(2) { allFlags().count == 0 })
    }

    // Nested cell (L1): decorator appears inside the L1 row edit form
    func testNestedCellLevel1DecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 2, in: app)
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]

        S.run(S.addCommand(path: l1CellPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 0, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        XCTAssertEqual(flag.label, "Flag")
        S.dismissRowEditForm(in: app)

        S.run(S.updateCommand(path: l1CellPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 0, in: app)
        XCTAssertTrue(waitUntil(2) { flag.label == "Done" })
        S.dismissRowEditForm(in: app)

        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 0, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        flag.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)
        S.dismissRowEditForm(in: app)

        S.run(S.removeCommand(path: l1CellPath, action: "flag"), in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 0, in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists })
        S.dismissRowEditForm(in: app)
    }

    // Nested cell (L2): decorator appears inside the L2 row edit form
    func testNestedCellLevel2DecoratorLifecycle() {
        typealias S = DecoratorUITestSupport
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 3, in: app)
        S.expandCollectionNestedRow(at: 1, in: app)
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]

        S.run(S.addCommand(path: l2CellPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 1, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        XCTAssertEqual(flag.label, "Flag")
        S.dismissRowEditForm(in: app)

        S.run(S.updateCommand(path: l2CellPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 1, in: app)
        XCTAssertTrue(waitUntil(2) { flag.label == "Done" })
        S.dismissRowEditForm(in: app)

        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 1, in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        flag.tap()
        XCTAssertTrue(waitUntil(2) {
            S.decoratorFocusEvent(action: "flag", in: self.focusBlurOptionalResults()) != nil
        })
        let fe = S.decoratorFocusEvent(action: "flag", in: focusBlurOptionalResults()) ?? [:]
        XCTAssertEqual(fe["type"] as? String, "flag")
        XCTAssertEqual(fe["target"] as? String, "flag")
        XCTAssertEqual(fe["pageID"] as? String, pageID)
        XCTAssertEqual(fe["fieldPositionId"] as? String, fpCollection)
        S.dismissRowEditForm(in: app)

        S.run(S.removeCommand(path: l2CellPath, action: "flag"), in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 1, in: app)
        XCTAssertTrue(waitUntil(2) { !flag.exists })
        S.dismissRowEditForm(in: app)
    }
}
