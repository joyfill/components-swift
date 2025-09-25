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

## Key APIs (at a glance)

 - DocumentEditor: Core editing context for a JoyDoc. Pass it to `Form` to render. See: [document-editor.md](./document-editor.md)
 - change(changes: [Change]): Programmatic updates (fields, table rows). See: [change.md](./change.md)
 - validate(): Run validation and get field-level results. See: [validate.md](./validate.md)
 - Change events: Observe onChange/onFocus/onBlur/uploads/capture/errors. See: [change-events.md](./change-events.md)

For parameters, properties, events, tables, charts, and formulas, see the docs below.

## Learn More

- Swift setup: https://docs.joyfill.io/docs/swift
- API reference: https://docs.joyfill.io/docs
- Formulas: https://docs.joyfill.io/docs/formulas
- Changelogs: https://docs.joyfill.io/docs/changelogs
