# ios-spm-bundle-issue-fix
Duplicate bundle issue fix for Plugins/Extensions targets with SwiftPM

### Before & After

<p>
<img src="https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/before.png?raw=true" style="width:30%;" />
<img src="https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/after.png?raw=true" style="width:31%;" />
</p>

## Use Xcode project sample `BundleSample/BundleSample.xcodeproj`

### Aggregated dynamic package is needed here

```
let package = Package(
    name: "Combined",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Combined",
            type: .dynamic,
            targets: ["Combined"]
        ),
    ],
    dependencies: [
        .package(path: "../../MyLib")
    ],
    targets: [
        .target(
            name: "Combined",
            dependencies: [
                .product(
                    name: "MyLib",
                    package: "MyLib"
                )
            ]
        ),
    ]
)
```

This Aggregated library dependes on MyLib which is by default static

```
let package = Package(
    name: "MyLib",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MyLib",
            targets: ["MyLib"]
        ),
    ],
    targets: [
        .target(
            name: "MyLib"
        ),
    ]
)
```
### Xcode configs

App target depends on `Combined` -> Embed without signing
Extension target depends on `Combined` -> Do not embed

### Create Run script in the app target to delete `Plugins/**/*.bundle` from all extension. And move top level bundle from `BundleSample.app/` to `BundleSample.app/Frameworks/Combine.framework`

Tick `For install builds only`, only required when making an Archive

```
#!/bin/bash
set -e

COMBINED_NAME="Combined.framework"

# Path to Plugins directory
PLUGINS_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Plugins"

# Path to .app bundle
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# Path to destination inside Combined.framework
COMBINED_FRAMEWORK_PATH="${APP_PATH}/Frameworks/${COMBINED_NAME}"

# 1. Delete all *.bundle in Plugins
if [ -d "${PLUGINS_PATH}" ]; then
    echo "Cleaning .bundle directories inside Plugins..."
    find "${PLUGINS_PATH}" -name "*.bundle" -type d -print -exec rm -rf {} +
    echo "Done cleaning .bundle files in Plugins."
else
    echo "No Plugins directory found at ${PLUGINS_PATH}. Skipping cleanup."
fi

# 2. Move top-level *.bundle files from .app to Combined.framework
if [ ! -d "${COMBINED_FRAMEWORK_PATH}" ]; then
    echo "❌ Error: ${COMBINED_NAME} does not exist at ${COMBINED_FRAMEWORK_PATH}"
    exit 1
fi

echo "Moving top-level .bundle files from .app to ${COMBINED_NAME}..."
find "${APP_PATH}" -maxdepth 1 -name "*.bundle" -type d -print -exec mv {} "${COMBINED_FRAMEWORK_PATH}" \;
echo "Done moving .bundle files to ${COMBINED_NAME}."

```

### Since Targets depends onto `Cobined` lib to it will look into the `Cobined.framework/` for the bundles

![alt tag](https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/config1.png?raw=true)

![alt tag](https://github.com/chanonly123/ios-spm-bundle-issue-fix/blob/main/config2.png?raw=true)


### References

https://forums.swift.org/t/ipa-size-increasing-while-migrating-from-carthage-to-swift-package-manager-in-application-with-multiple-extension-framework-targets/50315
https://forums.swift.org/t/swiftpm-cant-dynamically-link-resources/70573/4
