# SeenWords

SwiftUI prototype for learning vocabulary from real-life photos.

## What This Prototype Covers

- Camera-style scan result for a cafe menu scene.
- Suggested category with user override.
- Recommended words, scene phrases, and hidden simple words.
- Photo-memory review flow with simple spaced repetition choices.
- Library timeline for photos, categories, and learned words.
- Public/private scene packs such as "NZ Cafe Menu".
- Profile tab with mock users, learning goals, and a 1-minute level check.
- Per-user recommendation context shown on the camera result screen.
- Photo scan animation: outline pulse, scan sweep, and word chips revealing after capture.
- Scientific photo-first review loop: scene recall, active recall input, answer reveal, memory-strength scheduling, and session summary.

The current version uses local mock data. Real camera capture, OCR, and model-backed recommendations are intentionally left as the next implementation layer.

## Run In iOS Simulator

```sh
xcodebuild -project SceneWords.xcodeproj -scheme SceneWords -destination 'platform=iOS Simulator,name=iPhone 16' build
```

You can also open `SceneWords.xcodeproj` in Xcode and run the `SceneWords` scheme on any available iOS simulator.
