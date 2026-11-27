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

    /// The config must default to the opt-out state: disabled with all copy nil.
    func testRowDeleteConfirmationConfig_defaults() {
        let config = RowDeleteConfirmationConfig()
        XCTAssertFalse(config.isEnabled)
        XCTAssertNil(config.title)
        XCTAssertNil(config.description)
        XCTAssertNil(config.submitText)
        XCTAssertNil(config.cancelText)
        XCTAssertNil(config.bulkTitle)
        XCTAssertNil(config.bulkDescription)
        XCTAssertNil(config.bulkSubmitText)
    }

    /// Explicit values passed to the initializer must be preserved.
    func testRowDeleteConfirmationConfig_explicitValuesPreserved() {
        let config = RowDeleteConfirmationConfig(
            isEnabled: true,
            title: "Delete?",
            description: "Are you sure?",
            submitText: "Yes",
            cancelText: "No",
            bulkTitle: "Delete {count}?",
            bulkDescription: "Remove {count} rows?",
            bulkSubmitText: "Delete all"
        )
        XCTAssertTrue(config.isEnabled)
        XCTAssertEqual(config.title, "Delete?")
        XCTAssertEqual(config.description, "Are you sure?")
        XCTAssertEqual(config.submitText, "Yes")
        XCTAssertEqual(config.cancelText, "No")
        XCTAssertEqual(config.bulkTitle, "Delete {count}?")
        XCTAssertEqual(config.bulkDescription, "Remove {count} rows?")
        XCTAssertEqual(config.bulkSubmitText, "Delete all")
    }

    /// Fields must participate in `Equatable`.
    func testRowDeleteConfirmationConfig_equality() {
        XCTAssertEqual(RowDeleteConfirmationConfig(isEnabled: true, description: "x"),
                       RowDeleteConfirmationConfig(isEnabled: true, description: "x"))
        XCTAssertNotEqual(RowDeleteConfirmationConfig(isEnabled: true, description: "x"),
                          RowDeleteConfirmationConfig(isEnabled: false, description: "x"))
        XCTAssertNotEqual(RowDeleteConfirmationConfig(isEnabled: true, description: "x"),
                          RowDeleteConfirmationConfig(isEnabled: true, description: "y"))
        XCTAssertNotEqual(RowDeleteConfirmationConfig(isEnabled: true, bulkTitle: "a"),
                          RowDeleteConfirmationConfig(isEnabled: true, bulkTitle: "b"))
    }

    // MARK: resolved(count:) — defaults, overrides, {count} token

    /// A single-row delete with no overrides must use the single-row defaults.
    func testResolved_single_usesDefaults() {
        let r = RowDeleteConfirmationConfig().resolved(count: 1)
        XCTAssertEqual(r.title, RowDeleteConfirmationConfig.Defaults.title)
        XCTAssertEqual(r.description, RowDeleteConfirmationConfig.Defaults.description)
        XCTAssertEqual(r.submitText, RowDeleteConfirmationConfig.Defaults.submitText)
        XCTAssertEqual(r.cancelText, RowDeleteConfirmationConfig.Defaults.cancelText)
    }

    /// A multi-row delete with no overrides must use the bulk defaults and
    /// substitute the row count for `{count}`.
    func testResolved_bulk_usesBulkDefaultsAndCount() {
        let r = RowDeleteConfirmationConfig().resolved(count: 3)
        XCTAssertEqual(r.title, "Delete 3 rows?")
        XCTAssertEqual(r.description, "This action cannot be undone.")
        XCTAssertEqual(r.submitText, RowDeleteConfirmationConfig.Defaults.bulkSubmitText)
        XCTAssertEqual(r.cancelText, RowDeleteConfirmationConfig.Defaults.cancelText)
    }

    /// Single-row overrides must win over defaults; bulk fields stay unused.
    func testResolved_single_honorsOverrides() {
        let config = RowDeleteConfirmationConfig(title: "Remove row",
                                                 description: "Gone forever",
                                                 submitText: "Remove",
                                                 cancelText: "Keep",
                                                 bulkTitle: "SHOULD NOT SHOW")
        let r = config.resolved(count: 1)
        XCTAssertEqual(r.title, "Remove row")
        XCTAssertEqual(r.description, "Gone forever")
        XCTAssertEqual(r.submitText, "Remove")
        XCTAssertEqual(r.cancelText, "Keep")
    }

    /// `{count}` must be substituted inside custom bulk copy.
    func testResolved_bulk_substitutesCountInOverrides() {
        let config = RowDeleteConfirmationConfig(bulkTitle: "Delete {count} items",
                                                 bulkDescription: "{count} rows will be removed")
        let r = config.resolved(count: 5)
        XCTAssertEqual(r.title, "Delete 5 items")
        XCTAssertEqual(r.description, "5 rows will be removed")
    }

    /// `cancelText` is shared across single and bulk.
    func testResolved_cancelText_sharedAcrossSingleAndBulk() {
        let config = RowDeleteConfirmationConfig(cancelText: "Abort")
        XCTAssertEqual(config.resolved(count: 1).cancelText, "Abort")
        XCTAssertEqual(config.resolved(count: 4).cancelText, "Abort")
    }

    // MARK: editor seeding + runtime mutation

    /// A freshly created editor must default to the gate being off, so existing
    /// integrators keep deleting rows immediately until they opt in.
    func testEditor_rowDeleteConfirmation_defaultsDisabled() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(editor.rowDeleteConfirmation.description)
    }

    /// The editor must seed its gate from the config passed at init.
    func testEditor_rowDeleteConfirmation_seededFromConfig() {
        let gate = RowDeleteConfirmationConfig(isEnabled: true, description: "Careful")
        let editor = DocumentEditor(
            document: JoyDoc(),
            config: DocumentEditorConfig(validateSchema: false, rowDeleteConfirmation: gate)
        )
        XCTAssertTrue(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertEqual(editor.rowDeleteConfirmation.description, "Careful")
    }

    /// The seeded gate must remain runtime-settable after init.
    func testEditor_rowDeleteConfirmation_setDirectly() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))

        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig(
            isEnabled: true,
            description: "Deleting this asset will also delete any deficiencies that exist."
        )

        XCTAssertTrue(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertEqual(editor.rowDeleteConfirmation.description,
                       "Deleting this asset will also delete any deficiencies that exist.")
    }

    /// `description` passed alone must leave `isEnabled` at its false default — a
    /// description with no enable flag does not turn the gate on.
    func testRowDeleteConfirmationConfig_descriptionOnly_isEnabledFalse() {
        let config = RowDeleteConfirmationConfig(description: "warn")
        XCTAssertFalse(config.isEnabled)
        XCTAssertEqual(config.description, "warn")
    }

    /// The struct is a value type — mutating a copy must not affect the original.
    func testRowDeleteConfirmationConfig_valueSemantics() {
        let original = RowDeleteConfirmationConfig(isEnabled: true, description: "a")
        var copy = original
        copy.isEnabled = false
        copy.description = "b"
        XCTAssertTrue(original.isEnabled)
        XCTAssertEqual(original.description, "a")
        XCTAssertFalse(copy.isEnabled)
        XCTAssertEqual(copy.description, "b")
    }

    /// Re-assigning the editor's config must fully replace the previous value.
    func testEditor_rowDeleteConfirmation_reassignmentReplacesFully() {
        let editor = DocumentEditor(document: JoyDoc(),
                                    config: DocumentEditorConfig(validateSchema: false))
        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig(isEnabled: true, description: "x")
        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig()

        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(editor.rowDeleteConfirmation.description)
    }

    /// Two editors must hold independent gate configs — setting one must not
    /// leak onto the other.
    func testEditor_rowDeleteConfirmation_independentBetweenEditors() {
        let a = DocumentEditor(document: JoyDoc(),
                               config: DocumentEditorConfig(validateSchema: false))
        let b = DocumentEditor(document: JoyDoc(),
                               config: DocumentEditorConfig(validateSchema: false))

        a.rowDeleteConfirmation = RowDeleteConfirmationConfig(isEnabled: true, description: "x")

        XCTAssertTrue(a.rowDeleteConfirmation.isEnabled)
        XCTAssertFalse(b.rowDeleteConfirmation.isEnabled)
        XCTAssertNil(b.rowDeleteConfirmation.description)
    }

    /// Even when schema validation fails and the editor takes its early-return
    /// path, the gate must be seeded from config and remain settable.
    func testEditor_rowDeleteConfirmation_seededAndSettableOnInvalidSchemaEditor() {
        let gate = RowDeleteConfirmationConfig(isEnabled: true, description: "x")
        let editor = DocumentEditor(document: invalidDocument(),
                                    config: DocumentEditorConfig(validateSchema: true,
                                                                 rowDeleteConfirmation: gate))
        XCTAssertNotNil(editor.schemaError)
        XCTAssertTrue(editor.rowDeleteConfirmation.isEnabled) // seeded despite early return
        XCTAssertEqual(editor.rowDeleteConfirmation.description, "x")

        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig()
        XCTAssertFalse(editor.rowDeleteConfirmation.isEnabled)
    }

    // MARK: - Memory-leak regression (DocumentEditor retain cycle)

    /// Documents whose fields exercise the table/collection/chart/signature models that
    /// hold the editor back. If those references are strong, the editor forms a cycle with
    /// its own `pageFieldModels` and never deallocates — the whole parsed document stays in
    /// memory, and each reopen stacks another copy.
    private let leakProneDocuments = [
        "FieldTemplate_TableCollection_Poplated", // table + collection
        "Joydocjson",                             // mixed field types
        "ChangerHandlerUnit"                      // collection
    ]

    /// Opening a form builds `pageFieldModels`; the editor must still deallocate once the
    /// last strong reference goes away. Making a model's `documentEditor` non-weak brings
    /// the leak back and fails this test.
    func testDocumentEditorDeallocatesAfterUse() {
        for fileName in leakProneDocuments {
            weak var weakEditor: DocumentEditor?

            autoreleasepool {
                let document = sampleJSONDocument(fileName: fileName)
                let editor = DocumentEditor(document: document,
                                            config: DocumentEditorConfig(validateSchema: false))
                weakEditor = editor
                XCTAssertNotNil(weakEditor, "\(fileName): editor should be alive inside its scope")
            }

            drainMainQueue()
            XCTAssertNil(weakEditor,
                         "\(fileName): DocumentEditor leaked — a model in pageFieldModels is retaining it strongly")
        }
    }

    /// A collection builds its cells — and each cell's `didChange`/`didFocusBlur` closures —
    /// on a background queue. If a closure captures the view model strongly, the view model
    /// is retained by its own cells and leaks on every open.
    func testCollectionViewModelDeallocatesAfterBuildingCells() throws {
        // IDs of the collection field in ChangerHandlerUnit (shared with the delegate tests).
        let fileID = "685750ef698da1ab427761ba"
        let pageID = "685750efeb612f4fac5819dd"
        let collectionFieldID = "6857510fbfed1553e168161b"

        let document = sampleJSONDocument(fileName: "ChangerHandlerUnit")
        let editor = DocumentEditor(document: document,
                                    config: DocumentEditorConfig(validateSchema: false))

        weak var weakViewModel: CollectionViewModel?

        try autoreleasepool {
            let field = editor.field(fieldID: collectionFieldID)
            let header = FieldHeaderModel(title: field?.title,
                                          required: field?.required,
                                          tipDescription: field?.tipDescription,
                                          tipTitle: field?.tipTitle,
                                          tipVisible: field?.tipVisible,
                                          visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
            let tableDataModel = try XCTUnwrap(
                TableDataModel(fieldHeaderModel: header,
                               mode: .fill,
                               documentEditor: editor,
                               fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID,
                                                                pageID: pageID,
                                                                fileID: fileID)),
                "Could not build TableDataModel for the collection field")

            let viewModel = CollectionViewModel(tableDataModel: tableDataModel)
            weakViewModel = viewModel

            // The view model builds its cells (and their closures) on `dispatchQueue`, then
            // hops to main to store them. Wait for both so the closures that could form the
            // cycle actually exist before we release the view model.
            viewModel.dispatchQueue.sync { }
            drainMainQueue()
        }

        drainMainQueue()
        XCTAssertNil(weakViewModel,
                     "CollectionViewModel leaked — a cell closure is capturing self strongly")
    }

    /// Runs the main run loop until a block enqueued now has executed, so any
    /// `DispatchQueue.main.async` hop that still holds a reference has completed.
    private func drainMainQueue() {
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2.0)
    }
}
