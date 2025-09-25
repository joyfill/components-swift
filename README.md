![joyfill_logo](https://github.com/joyfill/examples/assets/5873346/4943ecf8-a718-4c97-a917-0c89db014e49)

# @joyfill/components-swift

Keep this README simple. For full setup and details, see the official Swift guide: https://docs.joyfill.io/docs/swift

## Overview

This repo provides Joyfill SDKs for Apple platforms (Swift, SwiftUI):

- Joyfill: UI components to display and interact with Joyfill documents (forms, tables, formulas).
- JoyFillModel: Data models with advanced field types and structures.
- JoyfillFormulas: Formula engine for calculations, strings, dates, arrays, and logic.
- JoyfillAPIService: Networking for the Joyfill API.

More APIs and concepts: https://docs.joyfill.io/docs

## Requirements

- iOS 15+ (minimum deployment target)

## Installation (Swift Package Manager)

In Xcode: File > Add Packages, then add this URL:

```
https://github.com/joyfill/components-swift
```

Choose the libraries you need and the desired version (latest recommended).

## Quick Start (SwiftUI)

Render a Joyfill document with the `Form` view using a `DocumentEditor`:

```swift
import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    let editor: DocumentEditor

    init(document: JoyDoc) {
        editor = DocumentEditor(document: document)
    }

    var body: some View {
        Form(documentEditor: editor)
    }
}
```

## Examples

- Sample JSON: [/first-form.json](https://github.com/joyfill/components-swift/blob/update-readme-file/JoyfillSwiftUIExample/JoyfillExample/Simple%20Form%20Example/first-form.json)
- Simple usage: [/SimpleFormExampleView](https://github.com/joyfill/components-swift/blob/update-readme-file/JoyfillSwiftUIExample/JoyfillExample/Simple%20Form%20Example/SimpleFormExampleView.swift)
- SwiftUI example app: [/JoyfillSwiftUIExample](https://github.com/joyfill/components-swift/tree/main/JoyfillSwiftUIExample)
- UIKit example app: [/JoyfillUIKitExample](https://github.com/joyfill/components-swift/tree/main/JoyfillUIKitExample)
- Flutter demo: [/joyfillflutterexample](https://github.com/joyfill/components-swift/tree/main/joyfillflutterexample)

## Key APIs

- DocumentEditor
  - Core editor for a `JoyDoc`; pass to `Form` to render.
  - Field validation: `validate()` checks field-level rules (e.g., required, formats).
  - Includes Change API (`change(changes:)`) for programmatic updates. See Change API section in [document-editor.md](./document-editor.md)
  - Guide: [document-editor.md](./document-editor.md)

- Schema validation
  - Checks document schema and version compatibility (separate from `DocumentEditor.validate()`).
  - Guide: [validate.md](./validate.md)

- Change events
  - Observe `onChange`, `onFocus`, `onBlur`, uploads, capture, and errors.
  - Guide: [change-events.md](./change-events.md)

For parameters, properties, events, tables, charts, and formulas, see the docs below.

## Learn More

- Swift setup: https://docs.joyfill.io/docs/swift
- API reference: https://docs.joyfill.io/docs
- Formulas: https://docs.joyfill.io/docs/formulas
- Changelogs: https://docs.joyfill.io/docs/changelogs
