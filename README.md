# HotTubLog

SwiftUI source for the Hot Tub maintenance log app, including an Xcode project.

## Quick start
1. On macOS, open `HotTubLog.xcodeproj` in Xcode.
2. Select your Team under Signing & Capabilities.
3. Build and run on a simulator or device.

## Notes
- Xcode only runs on macOS; Windows/WSL can edit the code but cannot build or run the app.
- Minimum iOS version: 18.2.
- Data is local-only using SwiftData.
- Photos are stored in the app's Documents directory.
- Reminders use local notifications; enable permissions when prompted.

## Preview without macOS
Use the CI workflow to build a simulator app and preview it in a browser.

1. Push to the `preview` branch (or run the `iOS Simulator Build` workflow manually).
2. Download the `HotTubLog-simulator-app` artifact (a zipped `.app` bundle).
3. Upload it to Appetize: <https://appetize.io/upload>
4. Select an iOS 18.2 (or newer) device in Appetize.

### Optional: auto-upload to Appetize from CI
Add these repo secrets to enable automatic uploads after each CI build:
- `APPETIZE_API_TOKEN`
- `APPETIZE_APP_PUBLIC_KEY`

The workflow posts the simulator zip directly to Appetize using their REST API.
