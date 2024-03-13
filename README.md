![joyfill_logo](https://github.com/joyfill/examples/assets/5873346/4943ecf8-a718-4c97-a917-0c89db014e49)

# @joyfill/components-swift
We recommend visiting our official Swift setup guide https://docs.joyfill.io/docs/swift.

## Project Requirements
Note userAccessTokens & identifiers will need to be stored on your end (usually on a user and set of existing form field-based data) in order to interact with our API and UI Components effectively

- minimum deployment target to iOS 13

## Install Dependency

### React-Native CLI (bare)

```shell npm
$ npm install @joyfill/components-react-native@latest react-native-webview react-native-svg @react-native-community/datetimepicker --save
$ cd ios && pod install
```
```Text Yarn
$ yarn add @joyfill/components-react-native@latest react-native-webview react-native-svg @react-native-community/datetimepicker
$ cd ios && pod install
```

### Expo (managed)

```shell npm
$ npx expo install @joyfill/components-react-native@latest react-native-webview react-native-svg @react-native-community/datetimepicker
```

## Implement your code

For full examples please see [https://docs.joyfill.io/docs/react-native](https://docs.joyfill.io/docs/react-native#implement-your-code).

Below is a usable example of our react-native document native embedded. This will show a readonly or fillable depending on the `mode` form to your users. The document (form) shown is based on your `documentId`.

Make sure to replace the `userAccessToken` and `documentId`. Note that `documentId` is just for this example, you can call our [List all documents](ref:list-all-documents) endpoint and grab an ID from there.

```javascript

import React, { useState, useEffect } from 'react';
import { Dimensions, View } from 'react-native';
import { joyfillRetrieve } from './api.js';
import { JoyDoc, getDefaultDocument } from '@joyfill/components-react-native';

const screenWidth = Dimensions.get('window').width;

const userAccessToken = '<REPLACE_ME>';
const documentId = '<REPLACE_ME>';

function Document() {

  const [doc, setDoc] = useState(getDefaultDocument());

  // retrieve the document from our api (you can also pass an initial documentId into JoyDoc)
  useEffect(() => {
    const response = await joyfillRetrieve(documentId, userAccessToken).then(doc => {
      setDoc(response);
    });
  }, []);

  return (
    <View style={{flex: 1}}>
      <JoyDoc
        mode="fill"
        doc={doc}
        width={screenWidth}
        onChange={(changelogs, doc) => {
          console.log('onChange doc: ', doc);
          setDoc(doc);
        }}
        onUploadAsync={async (params, fileUploads) => {
          // to see a full utilization of upload see api.js -> examples
          console.log('onUploadAsync: ', fileUploads);
        }}
      />
    </View>
  );
}

export default Document;

```

### JoyDoc Params

* `mode: 'fill' | 'readonly'`
  * **Required***
  * Enables and disables certain JoyDoc functionality and features. 
  * Options
    * `fill` is the mode where you simply input the field data into the form
    * `readonly` is the mode where everything in the form is set to read-only.
* `doc: object`
  * The JoyDoc JSON object to load into the SDK. Must be in the JoyDoc JSON data structure.
  * The SDK uses object reference equality checks to determine if the `doc` or any of its internal `pages` or `fields` have changed in the JSON. Ensure you’re creating new object instances when updating the document, pages, or fields before passing the updated `doc` JSON back to the SDK. This will ensure your changes are properly detected and reflected in the SDK.
* `initialPageId: string`
  * Specify the initial page to display in the form. 
  * Utilize the `_id` property of a Page object. For instance, `page._id`.
  * If page is not found within the `doc` it will fallback to displaying the first page in the `pages` array.
* `navigation: object`
  * Display/hide page navigation.
  * Set the `pages` property to true (display) or false (hide). For instance, `{pages: false}` hides the page navigation.
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

* `theme: object`
  * Specify custom theme properties.
  * Sample theme object `{ fontFamily: { regular: "Ariel", bold: "Ariel-bold" }, button: { primary: { fontWeight: "bold", borderRadius: "10px", ... } }` 
  * The button `primary`, `secondary`, and `danger` support the React Native Supported Styles
  * `fontFamily: object`
      * `fontFamily.regular: string`
      * `fontFamily.bold: string`
    * Apply custom font family to display text.
    * **IMPORTANT:** If you're using a custom font, you are responsible to ensure the fonts are loaded before rendering the component. Could result in an error if font is not loaded properly before render.
  * `button: object`
    * `button.primary: object` 
      * Specifies styles for primary field buttons.
    * `button.secondary: object`
      * Specifies styles for secondary internal field buttons.
    * `button.danger: object`
      * Specifies styles for delete buttons.

## SDK Helper Methods

* `getDefaultDocument`
  * Get a default Joyfill Document object
* `getDefaultTemplate`
  * Get a default Joyfill Template object
* `getDocumentFromTemplate: ( template: object )`
  * Generate a Joyfill Document object from a Joyfill Template object
* `duplicate: ( original: object, defaults: object )`
  * Duplicate a Joyfill Document or Template object.
* `duplicatePage: ( original: object, fileId: string, pageId: string )`
  * Duplicate a Joyfill Document or Template Page object.
  * Returns: `{ doc: object, changelogs: array }`
    * `doc` fully updated Document or Template with the page added
    * `changelogs` array of changelogs for new duplicate page.
* `applyLogic: ( items: object_array, fields: object_array, fieldLookupKey: string )`
  * Apply show/hide logic to pages and fields for external filtering.
  * Wrapper around `@joyfill/conditional-logic` library. [View library](https://github.com/joyfill/conditional-logic#readme)

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


