# 🧩 iOS SwiftPM Bundle Duplication Fix

Fixes duplicate `.bundle` files in `Plugins` directories when using Swift Package Manager (SPM) with app + extension targets.

### ✅ Before vs After  
<p>
  <img src="https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/before.png?raw=true" width="30%" />
  <img src="https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/after.png?raw=true" width="31%" />
</p>

---

## 🛠 Project Setup

Use the sample project: `BundleSample/BundleSample.xcodeproj`

### SPM Setup

**1. Aggregated dynamic library (`Combined`)**
```swift
// Combined/Package.swift
let package = Package(
    name: "Combined",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Combined", type: .dynamic, targets: ["Combined"])
    ],
    dependencies: [
        .package(path: "../../MyLib")
    ],
    targets: [
        .target(
            name: "Combined",
            dependencies: [.product(name: "MyLib", package: "MyLib")]
        )
    ]
)
```

**2. Dependency library (`MyLib`)**
```swift
// MyLib/Package.swift
let package = Package(
    name: "MyLib",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MyLib", targets: ["MyLib"])
    ],
    targets: [
        .target(name: "MyLib")
    ]
)
```

---

## ⚙️ Xcode Configuration

- **App target** → Depends on `Combined.framework` → *Embed without signing*  
- **Extension target** → Depends on `Combined.framework` → *Do not embed*

---

## 🧹 Run Script (App Target)

> Cleans up `.bundle` files from `Plugins`, and moves top-level `.bundle` files into `Combined.framework`.

Add this in **Build Phases > Run Script** (Check “For install builds only”):

```bash
#!/bin/bash
set -e

COMBINED_NAME="Combined.framework"
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
PLUGINS_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Plugins"
COMBINED_FRAMEWORK_PATH="${APP_PATH}/Frameworks/${COMBINED_NAME}"

# 1. Remove *.bundle from Plugins
if [ -d "${PLUGINS_PATH}" ]; then
    echo "Cleaning .bundle files in Plugins..."
    find "${PLUGINS_PATH}" -name "*.bundle" -type d -exec rm -rf {} +
fi

# 2. Move *.bundle into Combined.framework
if [ ! -d "${COMBINED_FRAMEWORK_PATH}" ]; then
    echo "❌ Error: ${COMBINED_NAME} not found"
    exit 1
fi

echo "Moving top-level .bundle files to ${COMBINED_NAME}..."
find "${APP_PATH}" -maxdepth 1 -name "*.bundle" -type d -exec mv {} "${COMBINED_FRAMEWORK_PATH}" \;
```

---

## ✅ Result

Now all targets refer to bundles inside `Combined.framework`, eliminating duplicates.

<img src="https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/config1.png?raw=true" width="40%" />
<img src="https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/config2.png?raw=true" width="40%" />

---

## 🔗 References

- [IPA size increasing while Migrating from Carthage to Swift Package Manager](https://forums.swift.org/t/ipa-size-increasing-while-migrating-from-carthage-to-swift-package-manager-in-application-with-multiple-extension-framework-targets/50315)
- [SwiftPM can’t dynamically link resources](https://forums.swift.org/t/swiftpm-cant-dynamically-link-resources/70573/4)
