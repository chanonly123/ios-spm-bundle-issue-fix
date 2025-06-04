# ios-spm-bundle-issue-fix
Duplicate bundle issue fix for Plugins/Extensions targets with SwiftPM

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

# Path to Plugins directory
PLUGINS_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Plugins"

# Path to .app bundle
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# Path to destination inside Combined.framework
COMBINED_FRAMEWORK_PATH="${APP_PATH}/Frameworks/Combined.framework"

# 1. Delete all *.bundle in Plugins
if [ -d "${PLUGINS_PATH}" ]; then
    echo "Cleaning .bundle directories inside Plugins..."
    find "${PLUGINS_PATH}" -name "*.bundle" -type d -print -exec rm -rf {} +
    echo "Done cleaning .bundle files in Plugins."
else
    echo "No Plugins directory found at ${PLUGINS_PATH}. Skipping cleanup."
fi

# 2. Move top-level *.bundle files from .app to Combined.framework
echo "Moving top-level .bundle files from .app to Combined.framework..."

# Create Combined.framework if it doesn't exist
mkdir -p "${COMBINED_FRAMEWORK_PATH}"

# Move only top-level *.bundle directories (not recursively)
find "${APP_PATH}" -maxdepth 1 -name "*.bundle" -type d -print -exec mv {} "${COMBINED_FRAMEWORK_PATH}" \;

echo "Done moving .bundle files to Combined.framework."

```

### Since Targets depends onto `Cobined` lib to it will look into the `Cobined.framework/` for the bundles