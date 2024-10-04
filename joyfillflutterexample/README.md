# Joyfill Flutter Example

This project demonstrates how to integrate the **Joyfill iOS SDK** into a Flutter app for seamless form-filling functionality.

## Requirements
- **Flutter** A Mac with flutter setup
- **iOS SDK** 15.0 or above
- **Xcode** 12 or above
- A Mac with **CocoaPods** installed

## Table of Contents
- [Step 1: Create a Flutter Project](#step-1-create-a-flutter-project)
- [Step 2: Modify iOS Project for SDK Integration](#step-2-modify-ios-project-for-sdk-integration)
- [Step 3: Add Joyfill SDK Dependency](#step-3-add-joyfill-sdk-dependency)
- [Step 4: Configure Swift Integration](#step-4-configure-swift-integration)
- [Step 5: Call Joyfill SDK from Flutter](#step-5-call-joyfill-sdk-from-flutter)
- [Step 6: Trigger Joyfill from Flutter](#step-6-trigger-joyfill-from-flutter)
- [Step 7: Run the App](#step-7-run-the-app)
- [Example Project](#example-project)
- [Troubleshooting](#troubleshooting)

## Step 1: Create a Flutter Project
If you haven't already created a Flutter project, you can do so by running the following command:

```bash
flutter create joyfill_flutter_example
cd joyfill_flutter_example
```

## Step 2: Modify iOS Project for SDK Integration

Navigate to the iOS part of the project:

```bash
cd ios
```

## Step 3: Add Joyfill SDK Dependency

Add the Joyfill SDK using Swift Package Manager:

In Xcode, with your `Runner.xcworkspace` project open from `/ios` directory, navigate to File > Add Packages.
When prompted, add the Joyfill Apple platforms SDK repository:

```
https://github.com/joyfill/components-swift
```

Select the SDK version you want to use (default is the latest). Choose the Joyfill libraries you want to use.

Xcode will automatically resolve and download your dependencies in the background.

## Step 4: Configure Swift Integration if required

Since Flutter uses Objective-C by default for iOS projects, you’ll need to ensure your project is configured for Swift.

- In Xcode, navigate to the `ios/Runner` directory and open `Runner.xcworkspace`.
- When prompted to create a bridging header for Swift, click **Yes**.

### Step 5: Call Joyfill SDK from Flutter

To bridge between Flutter and the native iOS Joyfill SDK, use Flutter's platform channels.

#### Example: Setting Up Platform Channel

- Open `ios/Runner/AppDelegate.swift`.
- Import the Joyfill SDK:

```swift
import Joyfill
import JoyfillModel
```

- Add code in `AppDelegate.swift` to handle communication with Flutter:

```swift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let registrar = self.registrar(forPlugin: "plugin-name") {
            registrar.register(FLNativeViewFactory(messenger: registrar.messenger()), withId: "JoyFill-FormView")
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

```

see [AppDelegate.swift](https://github.com/joyfill/components-swift/tree/main/joyfillflutterexample/ios/Runner/AppDelegate.swift) for more details.


Now to use following SwiftUI API from Joyfill to show form:

```swift
NavigationView {
  Form(document: documentBinding , mode: .fill, events: changeHandler, pageID: currentPage)
}
```

see [FormContainerViewController.swift](https://github.com/joyfill/components-swift/tree/main/joyfillflutterexample/ios/Runner/AppDelFormContainerViewControlleregate.swift) for more details.

Note: Form view must be wrped in `NavigationView` for the proper internal navigation.  

### Step 6: Trigger Joyfill from Flutter

In your Flutter app, create a UIKitView view to show joyfill form:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UiKitView(
                viewType: 'JoyFill-FormView', // Identifier for the native view.
                creationParams: null, 
                creationParamsCodec: null, 
                onPlatformViewCreated: (id) {},
              ),
    );
  }
}
```

## Step 7: Run the App

Ensure your iOS project is set up and run the Flutter app in iOS:

```bash
flutter run
```

## Example Project

We've added a complete Flutter integration example to the repository for reference. You can find it under the [/joyfillflutterexample](https://github.com/joyfill/components-swift/tree/main/joyfillflutterexample/) folder. To get started with it:

```bash
git clone https://github.com/joyfill/components-swift.git
cd joyfillflutterexample
flutter run
```

## Troubleshooting

If you run into issues, make sure that:
- You have the latest version of Flutter installed.
- You have the correct iOS version specified in the xcode.
- Your SPM dependencies are properly installed.

Feel free to open an issue on our GitHub repo if you need further assistance.

For more details on our iOS SDK see [README.md](https://github.com/joyfill/components-swift/blob/main/README.md)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
