import XCTest
import JoyfillModel
@testable import Joyfill

/// Loads the shared page copyable/deletable reference JoyDoc (components PR #60)
/// and checks menu offers plus `DocumentEditor.duplicatePage` against epic #1557.
final class PageCopyableDeletableReferenceTests: XCTestCase {

    private struct FixtureCase {
        let id: String
        let name: String
        let offer: PageDuplicateOffer
        let resolved: [CopyMode]
        let sourceDeletable: Bool
        let canDelete: Bool
    }

    private let cases: [FixtureCase] = [
        FixtureCase(id: "64f0c0110000000000000001", name: "Case 1: copyable missing", offer: .withValues, resolved: [.withValues], sourceDeletable: true, canDelete: true),
        FixtureCase(id: "64f0c0110000000000000002", name: "Case 2: copyable invalid", offer: .withValues, resolved: [.withValues], sourceDeletable: true, canDelete: true),
        FixtureCase(id: "64f0c0110000000000000003", name: "Case 3: with-values only", offer: .withValues, resolved: [.withValues], sourceDeletable: true, canDelete: true),
        FixtureCase(id: "64f0c0110000000000000004", name: "Case 4: without-values only", offer: .withoutValues, resolved: [.withoutValues], sourceDeletable: true, canDelete: true),
        FixtureCase(id: "64f0c0110000000000000005", name: "Case 5: with-values and without-values", offer: .both, resolved: [.withValues, .withoutValues], sourceDeletable: true, canDelete: true),
        FixtureCase(id: "64f0c0110000000000000006", name: "Case 6: none", offer: .hidden, resolved: [.none], sourceDeletable: true, canDelete: true),
        FixtureCase(id: "64f0c0110000000000000007", name: "Case 7: deletable false", offer: .withValues, resolved: [.withValues], sourceDeletable: false, canDelete: false),
        FixtureCase(id: "64f0c0110000000000000008", name: "Case 8: deletable missing", offer: .withoutValues, resolved: [.withoutValues], sourceDeletable: true, canDelete: true)
    ]

    private final class ChangeRecorder: FormChangeEvent {
        var changes: [Change] = []
        func onChange(changes: [Change], document: JoyDoc) { self.changes.append(contentsOf: changes) }
        func onFocus(event: Event) {}
        func onBlur(event: Event) {}
        func onUpload(event: UploadEvent) {}
        func onCapture(event: CaptureEvent) {}
        func onError(error: JoyfillError) {}
    }

    func testReferenceFixture_menuDeleteAndDuplicateForEveryCase() throws {
        let template = try loadDocument()

        for fixture in cases {
            let recorder = ChangeRecorder()
            let editor = makeEditor(document: template, events: recorder)
            guard let main = mainPage(editor, id: fixture.id),
                  let mobile = mobilePage(editor, id: fixture.id),
                  let menuPage = editor.firstPageFor(currentPageID: fixture.id) else {
                XCTFail("\(fixture.name): source main, mobile, or menu page missing")
                continue
            }

            XCTAssertEqual(main.copyable, fixture.resolved, "\(fixture.name): resolved main copyable")
            XCTAssertEqual(mobile.copyable, fixture.resolved, "\(fixture.name): resolved mobile copyable")
            XCTAssertEqual(main.duplicateOffer, fixture.offer, "\(fixture.name): main duplicate menu")
            XCTAssertEqual(mobile.duplicateOffer, fixture.offer, "\(fixture.name): mobile duplicate menu")
            XCTAssertEqual(menuPage.duplicateOffer, fixture.offer, "\(fixture.name): page sheet uses the mobile page when a mobile view exists")
            XCTAssertEqual(main.deletable, fixture.sourceDeletable, "\(fixture.name): main deletable")
            XCTAssertEqual(mobile.deletable, fixture.sourceDeletable, "\(fixture.name): mobile deletable")

            let showsDuplicate = editor.isPageDuplicateEnabled && menuPage.duplicateOffer != .hidden
            XCTAssertEqual(showsDuplicate, fixture.offer != .hidden, "\(fixture.name): duplicate button")
            let deleteResult = editor.canDeletePage(pageID: fixture.id)
            XCTAssertEqual(deleteResult.canDelete, fixture.canDelete, "\(fixture.name): canDeletePage")

            let sourceMainCopyable = copyableSignature(main)
            let sourceMobileCopyable = copyableSignature(mobile)
            let sourceMainDeletable = deletableSignature(main)
            let sourceMobileDeletable = deletableSignature(mobile)
            let sourceText = textValue(on: main, editor: editor)

            let copyWithValues = fixture.offer != .withoutValues
            editor.duplicatePage(pageID: fixture.id, copyWithValues: copyWithValues)

            guard let copyID = pageID(in: editor, after: fixture.id),
                  let mainCopy = mainPage(editor, id: copyID),
                  let mobileCopy = mobilePage(editor, id: copyID),
                  let sourceMain = mainPage(editor, id: fixture.id),
                  let sourceMobile = mobilePage(editor, id: fixture.id) else {
                XCTFail("\(fixture.name): duplicated main/mobile page missing")
                continue
            }

            XCTAssertEqual(copyableSignature(mainCopy), sourceMainCopyable, "\(fixture.name): main copy keeps source copyable exactly")
            XCTAssertEqual(copyableSignature(mobileCopy), copyableSignature(mainCopy), "\(fixture.name): mobile copy matches main copy copyable")
            XCTAssertEqual(mainCopy.copyable, fixture.resolved, "\(fixture.name): resolved copyable on the copy")
            XCTAssertEqual(mobileCopy.copyable, mainCopy.copyable, "\(fixture.name): resolved mobile copyable matches main")
            XCTAssertTrue(mainCopy.deletable, "\(fixture.name): main copy deletable")
            XCTAssertTrue(mobileCopy.deletable, "\(fixture.name): mobile copy deletable")
            XCTAssertEqual(deletableSignature(mainCopy), "true", "\(fixture.name): main copy writes deletable true")
            XCTAssertEqual(deletableSignature(mobileCopy), "true", "\(fixture.name): mobile copy writes deletable true")
            XCTAssertEqual(copyableSignature(sourceMain), sourceMainCopyable, "\(fixture.name): source main copyable unchanged")
            XCTAssertEqual(copyableSignature(sourceMobile), sourceMobileCopyable, "\(fixture.name): source mobile copyable unchanged")
            XCTAssertEqual(deletableSignature(sourceMain), sourceMainDeletable, "\(fixture.name): source main deletable unchanged")
            XCTAssertEqual(deletableSignature(sourceMobile), sourceMobileDeletable, "\(fixture.name): source mobile deletable unchanged")
            XCTAssertEqual(mainCopy.duplicateOffer, fixture.offer, "\(fixture.name): duplicate menu on the copy")

            let copiedText = textValue(on: mainCopy, editor: editor)
            if fixture.offer == .withoutValues {
                XCTAssertNil(copiedText, "\(fixture.name): without-values copy clears the text field")
            } else {
                XCTAssertEqual(copiedText, sourceText, "\(fixture.name): with-values copy keeps the text field")
            }
            XCTAssertEqual(textValue(on: sourceMain, editor: editor), sourceText, "\(fixture.name): source text unchanged")

            let pageCreates = recorder.changes.filter { $0.target == "page.create" }
            XCTAssertEqual(pageCreates.count, 2, "\(fixture.name): changelog has main and mobile page.create")
            for change in pageCreates {
                guard let pageDict = change.change?["page"] as? [String: Any] else {
                    XCTFail("\(fixture.name): page.create payload missing page")
                    continue
                }
                let created = Page(dictionary: pageDict)
                XCTAssertEqual(copyableSignature(created), sourceMainCopyable, "\(fixture.name): changelog copyable \(change.view ?? "main")")
                XCTAssertEqual(deletableSignature(created), "true", "\(fixture.name): changelog deletable \(change.view ?? "main")")
            }
        }
    }

    func testReferenceFixture_bothModesPreserveCopyableWhenCopyingWithoutValues() throws {
        let template = try loadDocument()
        let pageID = "64f0c0110000000000000005"
        let editor = makeEditor(document: template, events: nil)
        let sourceSignature = copyableSignature(try XCTUnwrap(mainPage(editor, id: pageID)))

        editor.duplicatePage(pageID: pageID, copyWithValues: false)

        let copyID = try XCTUnwrap(self.pageID(in: editor, after: pageID))
        let mainCopy = try XCTUnwrap(mainPage(editor, id: copyID))
        let mobileCopy = try XCTUnwrap(mobilePage(editor, id: copyID))
        XCTAssertEqual(copyableSignature(mainCopy), sourceSignature)
        XCTAssertEqual(copyableSignature(mobileCopy), sourceSignature)
        XCTAssertEqual(mainCopy.duplicateOffer, .both)
        XCTAssertNil(textValue(on: mainCopy, editor: editor))
        XCTAssertTrue(mainCopy.deletable)
        XCTAssertTrue(mobileCopy.deletable)
    }

    func testReferenceFixture_copyOfCopyKeepsWithoutValues() throws {
        let template = try loadDocument()
        let pageID = "64f0c0110000000000000004"
        let editor = makeEditor(document: template, events: nil)
        let source = try XCTUnwrap(mainPage(editor, id: pageID))
        let sourceSignature = copyableSignature(source)
        XCTAssertEqual(source.duplicateOffer, .withoutValues)

        editor.duplicatePage(pageID: pageID, copyWithValues: false)
        let firstCopyID = try XCTUnwrap(self.pageID(in: editor, after: pageID))
        editor.duplicatePage(pageID: firstCopyID, copyWithValues: false)
        let secondCopyID = try XCTUnwrap(self.pageID(in: editor, after: firstCopyID))

        for copyID in [firstCopyID, secondCopyID] {
            let mainCopy = try XCTUnwrap(mainPage(editor, id: copyID))
            let mobileCopy = try XCTUnwrap(mobilePage(editor, id: copyID))
            XCTAssertEqual(copyableSignature(mainCopy), sourceSignature, "copy \(copyID) keeps without-values")
            XCTAssertEqual(copyableSignature(mobileCopy), sourceSignature, "mobile copy \(copyID) matches")
            XCTAssertEqual(mainCopy.copyable, [.withoutValues])
            XCTAssertEqual(mainCopy.duplicateOffer, .withoutValues)
            XCTAssertTrue(mainCopy.deletable)
            XCTAssertTrue(mobileCopy.deletable)
        }

        let sourceAfter = try XCTUnwrap(mainPage(editor, id: pageID))
        XCTAssertEqual(copyableSignature(sourceAfter), sourceSignature)
        XCTAssertTrue(sourceAfter.deletable)
    }

    // MARK: - Helpers

    private func loadDocument() throws -> JoyDoc {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("pageCopyableDeletableReference.json")
        let data = try Data(contentsOf: url)
        let dictionary = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        return JoyDoc(dictionary: dictionary)
    }

    private func makeEditor(document: JoyDoc, events: FormChangeEvent?) -> DocumentEditor {
        DocumentEditor(
            document: document,
            config: DocumentEditorConfig(
                events: events,
                validateSchema: false,
                page: PageConfig(enableDuplicates: true, enableDeletes: true)
            )
        )
    }

    private func mainPage(_ editor: DocumentEditor, id: String) -> Page? {
        editor.document.files.first?.pages?.first { $0.id == id }
    }

    private func mobilePage(_ editor: DocumentEditor, id: String) -> Page? {
        editor.document.files.first?.views?.first?.pages?.first { $0.id == id }
    }

    private func pageID(in editor: DocumentEditor, after sourceID: String) -> String? {
        guard let order = editor.document.files.first?.pageOrder,
              let index = order.firstIndex(of: sourceID),
              index + 1 < order.count else { return nil }
        return order[index + 1]
    }

    private func textValue(on page: Page, editor: DocumentEditor) -> ValueUnion? {
        for position in page.fieldPositions ?? [] {
            guard let fieldID = position.field,
                  let field = editor.field(fieldID: fieldID),
                  field.fieldType == .text else { continue }
            return field.value
        }
        return nil
    }

    private func copyableSignature(_ page: Page) -> String {
        guard let value = page.dictionary["copyable"] else { return "missing" }
        if value is NSNull { return "null" }
        if let text = value as? String { return "string:\(text)" }
        if let modes = value as? [String] { return "array:" + modes.joined(separator: ",") }
        if let modes = value as? [Any] {
            return "array:" + modes.map { "\($0)" }.joined(separator: ",")
        }
        return "other:\(String(describing: value))"
    }

    private func deletableSignature(_ page: Page) -> String {
        guard let value = page.dictionary["deletable"] else { return "missing" }
        if let flag = value as? Bool { return flag ? "true" : "false" }
        if let number = value as? NSNumber { return number.boolValue ? "true" : "false" }
        return "other:\(String(describing: value))"
    }
}
