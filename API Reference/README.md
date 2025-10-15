# Joyfill iOS SDK - API Documentation

This directory (`API Reference`) contains the complete API reference documentation for all Joyfill iOS SDK modules, generated using Apple's DocC tool.

> **📂 Directory Location**: `/components-swift/API Reference/`  
> All documentation files are located within this directory.

## 📚 Available Modules

### 1. **Joyfill (UI Library)**
- **Path**: `Joyfill/documentation/joyfill/`
- **Description**: Main SwiftUI framework with document rendering and interactive form components
- **Platform**: iOS 15.0+

### 2. **JoyfillModel**
- **Path**: `JoyfillModel/documentation/joyfillmodel/`
- **Description**: Core data models and JSON schema structures
- **Platform**: iOS 15.0+

### 3. **JoyfillFormulas**
- **Path**: `JoyfillFormulas/documentation/joyfillformulas/`
- **Description**: Formula evaluation engine with expressions and functions
- **Platform**: iOS 15.0+

### 4. **JoyfillAPIService**
- **Path**: `JoyfillAPIService/documentation/joyfillapiservice/`
- **Description**: Network layer for Joyfill backend services
- **Platform**: iOS 15.0+

## 🚀 Viewing Documentation Locally

### Option 1: Using Python HTTP Server (Recommended)
```bash
cd "API Reference"
python3 -m http.server 8080
```

Then open your browser to: **http://localhost:8080**

### Option 2: Using Xcode DocC Preview
```bash
cd ..
xcodebuild docbuild -scheme Joyfill \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath ./DerivedData
```

Then open the generated `.doccarchive` files in Xcode.

### Option 3: Direct File Access
You can also open `index.html` directly in your browser, though some features may require a web server.

## 📖 Documentation Structure

Each module's documentation includes:
- **Overview**: Module purpose and capabilities
- **Topics**: Organized by functionality
- **Types**: Structs, classes, enums, and protocols
- **Functions**: Public API methods
- **Properties**: Public properties and constants
- **Extensions**: Extended functionality

### ⚠️ Cross-Module Linking Limitation

**Known Issue**: When viewing static documentation in a browser, cross-module links (e.g., `JoyDoc` references from the Joyfill module to JoyfillModel) may not work as clickable links. This is a limitation of DocC's static hosting feature when documentation is generated separately for each module.

**Workarounds**:
1. **Use Xcode DocC Viewer** (recommended): Open the documentation in Xcode where all cross-references work properly
2. **Use Search**: Each module has a built-in search feature to quickly find related types
3. **Manual Navigation**: Use the index page to navigate between modules

**Technical Note**: In-source documentation comments contain proper ``TypeName`` references, but when generating static sites for separate modules, DocC cannot resolve cross-module links at build time. For a fully linked documentation experience, view the documentation through Xcode or use a unified documentation bundle.

## 🔧 Regenerating Documentation

To regenerate the documentation:

```bash
# 1. Clean previous builds
rm -rf DerivedData "API Reference/Joyfill" "API Reference/JoyfillModel" "API Reference/JoyfillFormulas" "API Reference/JoyfillAPIService"

# 2. Build documentation symbols for iOS Simulator
xcodebuild docbuild \
  -scheme Joyfill \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath ./DerivedData

# 3. Convert Joyfill (UI) module with cross-references to all modules
xcrun docc convert \
  DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/Joyfill.build/symbol-graph/swift \
  --fallback-display-name Joyfill \
  --fallback-bundle-identifier com.joyfill.Joyfill \
  --fallback-bundle-version 1.0 \
  --additional-symbol-graph-dir DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/JoyfillModel.build/symbol-graph/swift \
  --additional-symbol-graph-dir DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/JoyfillFormulas.build/symbol-graph/swift \
  --additional-symbol-graph-dir DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/JoyfillAPIService.build/symbol-graph/swift \
  --output-path "./API Reference/Joyfill" \
  --transform-for-static-hosting \
  --hosting-base-path Joyfill

# 4. Convert JoyfillModel module
xcrun docc convert \
  DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/JoyfillModel.build/symbol-graph/swift \
  --allow-arbitrary-catalog-directories \
  --fallback-display-name JoyfillModel \
  --fallback-bundle-identifier com.joyfill.JoyfillModel \
  --fallback-bundle-version 1.0 \
  --output-path "./API Reference/JoyfillModel" \
  --transform-for-static-hosting \
  --hosting-base-path JoyfillModel

# 5. Convert JoyfillFormulas module
xcrun docc convert \
  DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/JoyfillFormulas.build/symbol-graph/swift \
  --allow-arbitrary-catalog-directories \
  --fallback-display-name JoyfillFormulas \
  --fallback-bundle-identifier com.joyfill.JoyfillFormulas \
  --fallback-bundle-version 1.0 \
  --output-path "./API Reference/JoyfillFormulas" \
  --transform-for-static-hosting \
  --hosting-base-path JoyfillFormulas

# 6. Convert JoyfillAPIService module
xcrun docc convert \
  DerivedData/Build/Intermediates.noindex/Joyfill.build/Debug-iphonesimulator/JoyfillAPIService.build/symbol-graph/swift \
  --allow-arbitrary-catalog-directories \
  --fallback-display-name JoyfillAPIService \
  --fallback-bundle-identifier com.joyfill.JoyfillAPIService \
  --fallback-bundle-version 1.0 \
  --output-path "./API Reference/JoyfillAPIService" \
  --transform-for-static-hosting \
  --hosting-base-path JoyfillAPIService

# 7. Start local server
cd "API Reference" && python3 -m http.server 8080
```

## 🎯 Platform Support

**iOS Only** - This SDK is specifically designed for iOS and does not support macOS, tvOS, or watchOS.

- **Minimum Deployment Target**: iOS 15.0
- **Swift Version**: 5.9+
- **Xcode**: 15.0+

## 📝 Notes

- Documentation is generated from inline code comments and attributes
- All public APIs are documented with descriptions and usage examples
- Symbol graphs are architecture-specific (arm64, x86_64 for simulator)
- Static hosting is optimized for web deployment

## 🔗 Links

- **Project Repository**: [Joyfill-iOS](https://github.com/joyfill/joyfill-ios)
- **Main Website**: [joyfill.io](https://joyfill.io)
- **Support**: Contact your Joyfill representative

---

*Generated on: October 15, 2025*  
*DocC Version: Latest*  
*Build Configuration: Debug-iphonesimulator*

