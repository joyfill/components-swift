![joyfill_logo](https://github.com/joyfill/examples/assets/5873346/4943ecf8-a718-4c97-a917-0c89db014e49)

# @joyfill/components-swift
We recommend visiting our official Swift setup guide https://docs.joyfill.io/docs/swift.

We offer three libraries for Swift entirely build in Swift and SwiftUI:

  **Joyfill**: The main library for integrating Joyfill into your Swift app. This library includes all the necessary UI components for displaying and interacting with Joyfill documents.

  **JoyFillModel**: A library for integrating Joyfill models into your Swift app. 

  **JoyfillAPIService**: A liberary for all the network interactions with the Joyfill API.

## Project Requirements
Note userAccessTokens & identifiers will need to be stored on your end (usually on a user and set of existing form field-based data) in order to interact with our API and UI Components effectively

See our [API Documentation](https://docs.joyfill.io/docs) for more information on how to interact with our API.

- Minimum deployment target to iOS 15

## Install Dependency


Add Joyfill SDKs to your app
Use Swift Package Manager to install and manage Joyfill dependencies.

In Xcode, with your app project open, navigate to File > Add Packages.
When prompted, add the Joyfill Apple platforms SDK repository:

```
  https://github.com/joyfill/components-swift
```

Select the SDK version that you want to use.

Note: We recommend using the default (latest) SDK version, but you can choose an older version if needed.
Choose the Joyfill libraries you want to use.

When finished, Xcode will automatically begin resolving and downloading your dependencies in the background.

## Getting Started

### Initilize the JoyfillAPIService

```swift
import JoyfillAPIService

@main
struct JoyfillExampleApp: App {
    init() {
        JoyfillAPIService.initialize(
        // Replace with your userAccessToken
            userAccessToken: "",
        // Replace with your baseURL
            baseURL: "https://api-joy.joyfill.io/v1")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Show a Joyfill Document with SwiftUI `JoyFillView` view

```swift
import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    @Binding var document: JoyDoc
    @State var currentPageID: String
    private let changeManager = ChangeManager()
    
    var body: some View {
        VStack {
            JoyFillView(document: $document, mode: .fill, events: changeManager, currentPageID: $currentPageID)
            SaveButtonView(changeManager: changeManager, document: $document)
        }
    }
}
```

See our example project for more details.

### JoyDoc Params

* `mode: 'fill' | 'readonly'`
  * Enables and disables certain JoyDoc functionality and features. 
  * Default is `fill`.
  * Options
    * `fill` is the mode where you simply input the field data into the form
    * `readonly` is the mode where everything in the form is set to read-only.
* `document: JoyDoc`
  * The JoyDoc JSON object to load into the SDK. Must be in the JoyDoc JSON data structure.
  * The SDK uses object reference equality checks to determine if the `doc` or any of its internal `pages` or `fields` have changed in the JSON. Ensure you’re creating new object instances when updating the document, pages, or fields before passing the updated `doc` JSON back to the SDK. This will ensure your changes are properly detected and reflected in the SDK.
* `currentPageID: String`
  * Specify the initial page to display in the form. 
  * Utilize the `_id` property of a Page object. For instance, `page._id`.
  * If page is not found within the `doc` it will fallback to displaying the first page in the `pages` array.
  * You can use this property to navigate to a specific page in the form.

* `events: FormChangeEvent`
  * Used to listen to form events.

### FormChangeEvent Params
* `onChange: (changelogs: object_array, doc: object) => {}` 
  * Used to listen to any field change events.
  * `changelogs: object_array`
    * Can contain one ore more of the changelog object types supported. [Learn more about changelogs](https://docs.joyfill.io/docs/changelogs)
  * `doc: object`
    * Fully updated JoyDoc JSON structure with changes applied.
* `onFocus: (params: object, e: object) => {}`
  * Used to listen to field focus events.
  * `params: object`
    * Specifies information about the focused field.
  * `e: object`
    * Element helper methods.
    * `blur: Function`
      * Triggers the field blur event for the focused field.
      * If there are pending changes in the field that have not triggered the `onChange` event yet then the `e.blur()` function will trigger both the change and blur events in the following order: 1) `onChange` 2) `onBlur`.
      * If the focused field utilizes a modal for field modification, ie. signature, image, tables, etc. the `e.blur()` will close the modal.
* `onBlur: (params: object) => {}`
  * Used to listen to field focus events.
  * `params: object`
    * Specifies information about the blurred field.
* `onUpload: (params: object) => {}`
  * Used to listen to file upload events.
  * `params: object`
    * Specifies information about the uploaded file.

## Field Events

* **Text**, **Textarea**, **Number**
    *  `onFocus(params: object, e: object)` is fired when the field is focused.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when the field is blurred.
*  **Date**, **Dropdown**
    *  `onFocus` is fired when the field is pressed and selection modal is displayed.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when the field is blurred and the selection modal is closed.
*  **Multiselect**
    *  `onFocus` is fired when an option is selected or unselected for the first time on the field.
    *  `onChange` is fired when an option is selected or unselected in the field.
*  **Chart**
    *  `onFocus` is fired when “view” button is pressed and modal is displayed.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when modal is closed.
*  **Image**
    *  `onFocus` is fired when “view” button is pressed and modal is displayed.
        *  An empty image field that is focused will also trigger the `onUploadAsync` request.
        *  A populated image field that is focused will trigger the image modal to open.
    *  `onChange` is fired when the field images are uploaded or removed.
    *  `onBlur` is fired when modal is closed.
* **Signature**
    *  `onFocus` is fired when open modal button is pressed and modal is displayed.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when the modal is closed.
*  **Table**
    *  `onFocus` is fired when “view” button is pressed and modal is displayed.
    *  `onBlur` is fired when modal is closed.
    * **Table Cells**
        * **Text Cell**
            * `onFocus` is fired when the cell is focused.
            * `onChange` is fired when the cell value is modified.
            * `onBlur` is fired when the cell is blurred
        * **Dropdown Cell**
            *  `onFocus` is fired when the cell is pressed and selection modal is displayed.
            *  `onChange` is fired when the field value is modified.
            *  `onBlur` is fired when the cell is blurred and the selection modal is closed.
        * **Image Cell**
            *  `onFocus` is fired cell is pressed and modal is displayed.
                *  An empty image cell that is focused will also trigger the `onUploadAsync` request.
                *  A populated image cell that is focused will trigger the image modal to open.
            *  `onChange` is fired when the cell images are uploaded or removed.
            *  `onBlur` is fired when modal is closed.

**IMPORTANT NOTE:** JoyDoc SDK `onFocus`, `onChange` and `onBlur` events are not always called in the same order. Two different fields can be triggering events at the same time.  For instance, if you have Field A focused and then focus on Field B, the Field B onFocus event could be fired before the Field A onBlur event. Always check the event params object ids to match up the associated field events.


