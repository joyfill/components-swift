import XCTest
import JoyfillModel
@testable import Joyfill

/// Verifies the new `DocumentEditor.init(document:events:config:)` correctly
/// maps a `DocumentEditorConfig` onto the editor, stays equivalent to the
/// legacy parameter-based init, and preserves the readonly coercion rule.
final class DocumentEditorConfigTests: XCTestCase {

    // MARK: - Test doubles

    /// Captures `onError` so schema-validation behaviour can be asserted.
    private final class MockFormChangeEvent: FormChangeEvent {
        private(set) var didReceiveError = false
        private(set) var receivedError: JoyfillError?

        func onChange(changes: [Change], document: JoyDoc) {}
        func onFocus(event: Event) {}
        func onBlur(event: Event) {}
        func onUpload(event: UploadEvent) {}
        func onCapture(event: CaptureEvent) {}
        func onError(error: JoyfillError) {
            didReceiveError = true
            receivedError = error
        }
    }

    /// A document that intentionally fails schema validation (missing required fields).
    private func invalidDocument() -> JoyDoc {
        JoyDoc(dictionary: [
            "identifier": "test-doc",
            "name": "Invalid Doc"
        ])
    }

    /// A valid multi-page document built from the shared dummy-model helpers.
    private func multiPageDocument() -> JoyDoc {
        JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()   // page id: "6629fab320fca7c8107a6cf6"
            .addSecondPage()              // page id: "second_page_id_12345"
            .setHeadingText()
            .setTextField()
    }

    // MARK: - Field mapping

    /// Every config field should land on the matching editor property.
    func testConfigInit_mapsAllValuesOntoEditor() {
        let config = DocumentEditorConfig(
            mode: .fill,
            license: nil,
            validateSchema: false,
            page: PageConfig(navigation: false,
                             enableDuplicates: true,
                             enableDeletes: true,
                             currentPageID: nil),
            display: DisplayConfig(singleClickRowEdit: true,
                                   decorators: DecoratorConfig(visibleLimitInFields: 5,
                                                               visibleLimitInRows: 3,
                                                               showInBulkForm: false),
                                   enableRowDuplicates: false,
                                   fullWidthGrid: true)
        )

        let editor = DocumentEditor(document: JoyDoc(), config: config)

        XCTAssertEqual(editor.mode, .fill)
        XCTAssertFalse(editor.showPageNavigationView)        // page.navigation
        XCTAssertTrue(editor.isPageDuplicateEnabled)         // page.enableDuplicates
        XCTAssertTrue(editor.isPageDeleteEnabled)            // page.enableDeletes
        XCTAssertTrue(editor.singleClickRowEdit)             // display.singleClickRowEdit
        XCTAssertEqual(editor.decoratorConfig.visibleLimitInFields, 5)
        XCTAssertEqual(editor.decoratorConfig.visibleLimitInRows, 3)
        XCTAssertFalse(editor.decoratorConfig.showInBulkForm)   // display.decorators.showInBulkForm
        XCTAssertFalse(editor.enableRowDuplicates)           // display.enableRowDuplicates
        XCTAssertTrue(editor.fullWidthGrid)                  // display.fullWidthGrid
    }

    /// Row duplication is disabled unless a host explicitly opts in.
    func testConfigInit_enableRowDuplicates_defaultsFalse() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        XCTAssertFalse(editor.enableRowDuplicates)
    }

    /// The opt-in must survive even when schema validation fails and the init takes its early-return branch.
    func testConfigInit_invalidDoc_stillCarriesEnableRowDuplicates() {
        let editor = DocumentEditor(
            document: invalidDocument(),
            config: DocumentEditorConfig(
                validateSchema: true,
                display: DisplayConfig(enableRowDuplicates: false)
            )
        )
        XCTAssertNotNil(editor.schemaError)        // early-return path taken
        XCTAssertFalse(editor.enableRowDuplicates) // ...and the flag still mapped
    }

    /// The opt-in must survive even when schema validation fails and the init takes its early-return branch.
    func testConfigInit_invalidDoc_stillCarriesFullWidthGrid() {
        let editor = DocumentEditor(
            document: invalidDocument(),
            config: DocumentEditorConfig(
                validateSchema: true,
                display: DisplayConfig(fullWidthGrid: true)
            )
        )
        XCTAssertNotNil(editor.schemaError)     // early-return path taken
        XCTAssertTrue(editor.fullWidthGrid)     // ...and the flag still mapped
    }

    /// The runtime setter is the only public write path; it must flip the published flag both ways.
    func testSetFullWidthGrid_updatesPublishedFlag() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        XCTAssertFalse(editor.fullWidthGrid) // default
        editor.setFullWidthGrid(true)
        XCTAssertTrue(editor.fullWidthGrid)
        editor.setFullWidthGrid(false)
        XCTAssertFalse(editor.fullWidthGrid)
    }

    // MARK: - Readonly coercion

    /// Readonly mode must force page duplicate/delete off, even if the config
    /// asked for them — same rule the legacy init enforces.
    func testConfigInit_readonlyForcesPageEditingOff() {
        let config = DocumentEditorConfig(
            mode: .readonly,
            validateSchema: false,
            page: PageConfig(enableDuplicates: true, enableDeletes: true)
        )

        let editor = DocumentEditor(document: JoyDoc(), config: config)

        XCTAssertEqual(editor.mode, .readonly)
        XCTAssertFalse(editor.isPageDuplicateEnabled)
        XCTAssertFalse(editor.isPageDeleteEnabled)
    }

    // MARK: - Defaults parity

    /// A default config must produce the same editor as the legacy init's defaults.
    ///
    /// Deliberately calls the deprecated overload — that is the thing under test.
    /// Marking the method deprecated suppresses the expected warning at that call.
    @available(*, deprecated, message: "Intentionally exercises the deprecated initializer.")
    func testConfigInit_defaultsMatchLegacyInit() {
        let legacy = DocumentEditor(document: JoyDoc(), validateSchema: false)
        let viaConfig = DocumentEditor(document: JoyDoc(),
                                       config: DocumentEditorConfig(validateSchema: false))

        XCTAssertEqual(legacy.mode, viaConfig.mode)
        XCTAssertEqual(legacy.showPageNavigationView, viaConfig.showPageNavigationView)
        XCTAssertEqual(legacy.isPageDuplicateEnabled, viaConfig.isPageDuplicateEnabled)
        XCTAssertEqual(legacy.isPageDeleteEnabled, viaConfig.isPageDeleteEnabled)
        XCTAssertEqual(legacy.singleClickRowEdit, viaConfig.singleClickRowEdit)
        XCTAssertEqual(legacy.decoratorConfig.visibleLimitInFields,
                       viaConfig.decoratorConfig.visibleLimitInFields)
        XCTAssertEqual(legacy.decoratorConfig.visibleLimitInRows,
                       viaConfig.decoratorConfig.visibleLimitInRows)
    }

    /// Sanity-check that the struct defaults themselves match the legacy init defaults,
    /// independent of how the editor consumes them.
    func testConfigDefaults_matchLegacyParameterDefaults() {
        let config = DocumentEditorConfig()

        XCTAssertEqual(config.mode, .fill)
        XCTAssertNil(config.license)
        XCTAssertTrue(config.validateSchema)
        XCTAssertTrue(config.page.navigation)
        XCTAssertFalse(config.page.enableDuplicates)
        XCTAssertFalse(config.page.enableDeletes)
        XCTAssertNil(config.page.currentPageID)
        XCTAssertFalse(config.display.singleClickRowEdit)
        XCTAssertEqual(config.display.decorators.visibleLimitInFields,
                       DecoratorConfig().visibleLimitInFields)
        XCTAssertEqual(config.display.decorators.visibleLimitInRows,
                       DecoratorConfig().visibleLimitInRows)
        XCTAssertTrue(config.display.decorators.showInBulkForm)
    }

    // MARK: - DecoratorConfig.showInBulkForm

    /// `showInBulkForm` must default to `true` so existing integrators keep
    /// seeing decorators in the bulk form unless they opt out.
    func testDecoratorConfig_showInBulkForm_defaultsTrue() {
        XCTAssertTrue(DecoratorConfig().showInBulkForm)
        XCTAssertTrue(DecoratorConfig(visibleLimitInFields: 9, visibleLimitInRows: 9).showInBulkForm)
    }

    /// An explicit `showInBulkForm` value must be preserved by the initializer.
    func testDecoratorConfig_showInBulkForm_explicitValuePreserved() {
        XCTAssertFalse(DecoratorConfig(showInBulkForm: false).showInBulkForm)
        XCTAssertTrue(DecoratorConfig(showInBulkForm: true).showInBulkForm)
    }

    /// `showInBulkForm` must participate in `Equatable` — two configs that differ
    /// only in that flag are not equal.
    func testDecoratorConfig_showInBulkForm_affectsEquality() {
        XCTAssertNotEqual(DecoratorConfig(showInBulkForm: true),
                          DecoratorConfig(showInBulkForm: false))
        XCTAssertEqual(DecoratorConfig(showInBulkForm: false),
                       DecoratorConfig(showInBulkForm: false))
    }

    /// The editor must default `decoratorConfig.showInBulkForm` to `true` when the
    /// config leaves the decorators untouched.
    func testConfigInit_defaultDecorators_keepShowInBulkFormTrue() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        XCTAssertTrue(editor.decoratorConfig.showInBulkForm)
    }

    /// `showInBulkForm` set through `DisplayConfig` must survive onto the editor
    /// even when the invalid-schema early-return path runs.
    func testConfigInit_invalidDoc_stillCarriesShowInBulkForm() {
        let editor = DocumentEditor(
            document: invalidDocument(),
            config: DocumentEditorConfig(
                validateSchema: true,
                display: DisplayConfig(decorators: DecoratorConfig(showInBulkForm: false))
            )
        )
        XCTAssertNotNil(editor.schemaError)                   // early-return path taken
        XCTAssertFalse(editor.decoratorConfig.showInBulkForm) // ...and the flag still mapped
    }

    // MARK: - Non-default legacy ↔ config equivalence

    /// With NON-default values the config init must produce the same editor as the
    /// legacy init given the equivalent parameters — this guards the delegation mapping.
    @available(*, deprecated, message: "Intentionally exercises the deprecated initializer.")
    func testConfigInit_matchesLegacyInit_withNonDefaultValues() {
        let decorators = DecoratorConfig(visibleLimitInFields: 7, visibleLimitInRows: 4)

        let legacy = DocumentEditor(
            document: JoyDoc(),
            mode: .fill,
            events: nil,
            pageID: nil,
            navigation: false,
            isPageDuplicateEnabled: true,
            isPageDeleteEnabled: true,
            validateSchema: false,
            license: nil,
            singleClickRowEdit: true,
            decoratorConfig: decorators
        )

        let viaConfig = DocumentEditor(
            document: JoyDoc(),
            config: DocumentEditorConfig(
                mode: .fill,
                license: nil,
                validateSchema: false,
                page: PageConfig(navigation: false,
                                 enableDuplicates: true,
                                 enableDeletes: true,
                                 currentPageID: nil),
                display: DisplayConfig(singleClickRowEdit: true, decorators: decorators)
            )
        )

        XCTAssertEqual(legacy.mode, viaConfig.mode)
        XCTAssertEqual(legacy.showPageNavigationView, viaConfig.showPageNavigationView)
        XCTAssertEqual(legacy.isPageDuplicateEnabled, viaConfig.isPageDuplicateEnabled)
        XCTAssertEqual(legacy.isPageDeleteEnabled, viaConfig.isPageDeleteEnabled)
        XCTAssertEqual(legacy.singleClickRowEdit, viaConfig.singleClickRowEdit)
        XCTAssertEqual(legacy.decoratorConfig.visibleLimitInFields,
                       viaConfig.decoratorConfig.visibleLimitInFields)
        XCTAssertEqual(legacy.decoratorConfig.visibleLimitInRows,
                       viaConfig.decoratorConfig.visibleLimitInRows)
    }

    // MARK: - License → isCollectionFieldEnabled

    /// A nil license must leave collection fields disabled.
    func testConfigInit_nilLicense_keepsCollectionDisabled() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(license: nil,
                                                                 validateSchema: false))
        XCTAssertFalse(editor.isCollectionFieldEnabled)
    }

    /// A *valid* license supplied through the config must actually flip
    /// `isCollectionFieldEnabled` to `true`. Paired with the nil-license test above,
    /// this guards the config → license mapping in both directions: dropping or
    /// zeroing `license` on the config path would leave the flag `false` and fail here.
    func testConfigInit_validLicense_enablesCollectionField() {
        let license = (ProcessInfo.processInfo.environment["JOYFILL_TEST_LICENSE"] ?? licenseKey)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(license.isEmpty,
                       "Missing license: set JOYFILL_TEST_LICENSE env var or check licenseKey")
        XCTAssertTrue(LicenseValidator.isCollectionEnabled(licenseToken: license),
                      "License verification failed — the token does not match the public key in LicenseValidator")

        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(license: license,
                                                                 validateSchema: false))

        XCTAssertTrue(editor.isCollectionFieldEnabled,
                      "A valid license passed via DocumentEditorConfig must enable collection fields.")
    }

    // MARK: - validateSchema behaviour

    /// validateSchema = true on an invalid document must record a schema error
    /// and fire `onError` through the events handler.
    func testConfigInit_validateSchemaTrue_invalidDoc_setsErrorAndFiresOnError() {
        let events = MockFormChangeEvent()
        let editor = DocumentEditor(document: invalidDocument(),
                                    config: DocumentEditorConfig(events: events, validateSchema: true))

        XCTAssertNotNil(editor.schemaError)
        XCTAssertEqual(editor.schemaError?.code, "ERROR_SCHEMA_VALIDATION")
        XCTAssertTrue(events.didReceiveError)
        if case .schemaValidationError = events.receivedError {
            // expected
        } else {
            XCTFail("Expected a schemaValidationError, got \(String(describing: events.receivedError))")
        }
    }

    /// validateSchema = false must skip validation entirely — no error even on an
    /// otherwise-invalid document.
    func testConfigInit_validateSchemaFalse_invalidDoc_skipsValidation() {
        let events = MockFormChangeEvent()
        let editor = DocumentEditor(document: invalidDocument(),
                                    config: DocumentEditorConfig(events: events, validateSchema: false))

        XCTAssertNil(editor.schemaError)
        XCTAssertFalse(events.didReceiveError)
    }

    // MARK: - currentPageID

    /// A `currentPageID` pointing at a real page must resolve to that page.
    func testConfigInit_currentPageID_resolvesToRequestedPage() {
        let config = DocumentEditorConfig(
            validateSchema: false,
            page: PageConfig(currentPageID: "second_page_id_12345")
        )

        let editor = DocumentEditor(document: multiPageDocument(), config: config)

        XCTAssertEqual(editor.currentPageID, "second_page_id_12345")
    }

    /// A nil `currentPageID` must fall back to the document's first valid page,
    /// matching the legacy init with `pageID: nil`.
    @available(*, deprecated, message: "Intentionally exercises the deprecated initializer.")
    func testConfigInit_nilCurrentPageID_matchesLegacyFirstValidPage() {
        let legacy = DocumentEditor(document: multiPageDocument(),
                                    pageID: nil,
                                    validateSchema: false)
        let viaConfig = DocumentEditor(document: multiPageDocument(),
                                       config: DocumentEditorConfig(validateSchema: false))

        XCTAssertEqual(legacy.currentPageID, viaConfig.currentPageID)
    }

    // MARK: - events passthrough

    /// The events handler passed alongside the config must be retained on the editor.
    func testConfigInit_eventsArePassedThrough() {
        let events = MockFormChangeEvent()
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(events: events, validateSchema: false))

        XCTAssertNotNil(editor.events)
        XCTAssertTrue((editor.events as AnyObject) === events)
    }

    // MARK: - Independence / swap

    /// Two different configs applied to the same document must produce two
    /// independent editors — supporting the "hold and swap config" use case.
    func testConfigInit_distinctConfigs_produceIndependentEditors() {
        let fillConfig = DocumentEditorConfig(
            mode: .fill,
            validateSchema: false,
            page: PageConfig(navigation: true, enableDuplicates: true, enableDeletes: true),
            display: DisplayConfig(singleClickRowEdit: true)
        )
        let readonlyConfig = DocumentEditorConfig(
            mode: .readonly,
            validateSchema: false,
            page: PageConfig(navigation: false, enableDuplicates: true, enableDeletes: true),
            display: DisplayConfig(singleClickRowEdit: false)
        )

        let fillEditor = DocumentEditor(document: JoyDoc(), config: fillConfig)
        let readonlyEditor = DocumentEditor(document: JoyDoc(), config: readonlyConfig)

        // Fill editor honours the requested values.
        XCTAssertEqual(fillEditor.mode, .fill)
        XCTAssertTrue(fillEditor.showPageNavigationView)
        XCTAssertTrue(fillEditor.isPageDuplicateEnabled)
        XCTAssertTrue(fillEditor.isPageDeleteEnabled)
        XCTAssertTrue(fillEditor.singleClickRowEdit)

        // Readonly editor is independent and applies the readonly coercion.
        XCTAssertEqual(readonlyEditor.mode, .readonly)
        XCTAssertFalse(readonlyEditor.showPageNavigationView)
        XCTAssertFalse(readonlyEditor.isPageDuplicateEnabled)
        XCTAssertFalse(readonlyEditor.isPageDeleteEnabled)
        XCTAssertFalse(readonlyEditor.singleClickRowEdit)
    }

    // MARK: - rowDeleteConfirmation

    /// The config must default to the opt-out state: disabled with no message.
    func testRowDeleteConfirmationConfig_defaults() {
        let config = RowDeleteConfirmationConfig()
        XCTAssertFalse(config.isEnabled)
        XCTAssertNil(config.message)
    }

    /// Explicit values passed to the initializer must be preserved.
    func testRowDeleteConfirmationConfig_explicitValuesPreserved() {
        let config = RowDeleteConfirmationConfig(isEnabled: true, message: "Are you sure?")
        XCTAssertTrue(config.isEnabled)
        XCTAssertEqual(config.message, "Are you sure?")
    }

    /// Both fields must participate in `Equatable`.
    func testRowDeleteConfirmationConfig_equality() {
        XCTAssertEqual(RowDeleteConfirmationConfig(isEnabled: true, message: "x"),
                       RowDeleteConfirmationConfig(isEnabled: true, message: "x"))
        XCTAssertNotEqual(RowDeleteConfirmationConfig(isEnabled: true, message: "x"),
                          RowDeleteConfirmationConfig(isEnabled: false, message: "x"))
        XCTAssertNotEqual(RowDeleteConfirmationConfig(isEnabled: true, message: "x"),
                          RowDeleteConfirmationConfig(isEnabled: true, message: "y"))
    }

    /// A freshly created editor must default to the gate being off, so existing
    /// integrators keep deleting rows immediately until they opt in.
    func testEditor_rowDeleteConfirmation_defaultsDisabled() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(editor.rowDeleteConfirmation.message)
    }

    /// The gate is configured directly on the editor (not via init); setting it
    /// must take effect and preserve both fields.
    func testEditor_rowDeleteConfirmation_setDirectly() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))

        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig(
            isEnabled: true,
            message: "Deleting this asset will also delete any deficiencies that exist."
        )

        XCTAssertTrue(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertEqual(editor.rowDeleteConfirmation.message,
                       "Deleting this asset will also delete any deficiencies that exist.")
    }

    /// `isEnabled` passed alone must leave `message` at its nil default.
    func testRowDeleteConfirmationConfig_isEnabledOnly_messageNil() {
        let config = RowDeleteConfirmationConfig(isEnabled: true)
        XCTAssertTrue(config.isEnabled)
        XCTAssertNil(config.message)
    }

    /// `message` passed alone must leave `isEnabled` at its false default — a
    /// message with no enable flag does not turn the gate on.
    func testRowDeleteConfirmationConfig_messageOnly_isEnabledFalse() {
        let config = RowDeleteConfirmationConfig(message: "warn")
        XCTAssertFalse(config.isEnabled)
        XCTAssertEqual(config.message, "warn")
    }

    /// An empty-string message must be distinct from a nil message for equality.
    func testRowDeleteConfirmationConfig_emptyMessageNotEqualNil() {
        XCTAssertNotEqual(RowDeleteConfirmationConfig(isEnabled: true, message: ""),
                          RowDeleteConfirmationConfig(isEnabled: true, message: nil))
    }

    /// The struct is a value type — mutating a copy must not affect the original.
    func testRowDeleteConfirmationConfig_valueSemantics() {
        let original = RowDeleteConfirmationConfig(isEnabled: true, message: "a")
        var copy = original
        copy.isEnabled = false
        copy.message = "b"
        XCTAssertTrue(original.isEnabled)
        XCTAssertEqual(original.message, "a")
        XCTAssertFalse(copy.isEnabled)
        XCTAssertEqual(copy.message, "b")
    }

    /// Re-assigning the editor's config must fully replace the previous value,
    /// including clearing a message back to nil.
    func testEditor_rowDeleteConfirmation_reassignmentReplacesFully() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig(isEnabled: true, message: "x")
        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig()

        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(editor.rowDeleteConfirmation.message)
    }

    /// Two editors must hold independent gate configs — setting one must not
    /// leak onto the other.
    func testEditor_rowDeleteConfirmation_independentBetweenEditors() {
        let a = DocumentEditor(document: JoyDoc(),
                               config: DocumentEditorConfig(validateSchema: false))
        let b = DocumentEditor(document: JoyDoc(),
                               config: DocumentEditorConfig(validateSchema: false))

        a.rowDeleteConfirmation = RowDeleteConfirmationConfig(isEnabled: true, message: "x")

        XCTAssertTrue(a.rowDeleteConfirmation.isEnabled)
        XCTAssertFalse(b.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(b.rowDeleteConfirmation.message)
    }

    /// The gate is unrelated to `DisplayConfig` — setting other display flags via
    /// the config must leave `rowDeleteConfirmation` at its disabled default.
    func testEditor_rowDeleteConfirmation_unaffectedByDisplayConfig() {
        let editor = DocumentEditor(
            document: JoyDoc(),
            config: DocumentEditorConfig(
                validateSchema: false,
                display: DisplayConfig(singleClickRowEdit: true,
                                       enableRowDuplicates: true,
                                       fullWidthGrid: true)
            )
        )
        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(editor.rowDeleteConfirmation.message)
    }

    /// Even when schema validation fails and the editor takes its early-return
    /// path, the gate must still be settable and readable.
    func testEditor_rowDeleteConfirmation_settableOnInvalidSchemaEditor() {
        let editor = DocumentEditor(document: invalidDocument(),
                                    config: DocumentEditorConfig(validateSchema: true))
        XCTAssertNotNil(editor.schemaError)
        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled) // default survives

        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig(isEnabled: true, message: "x")
        XCTAssertTrue(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertEqual(editor.rowDeleteConfirmation.message, "x")
    }
}
