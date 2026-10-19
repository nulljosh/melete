![Thinkpond iOS](icon.svg)

# Thinkpond iOS

![version](https://img.shields.io/badge/version-3.1-blue) ![license](https://img.shields.io/badge/license-MIT-green)

Native iPhone app for [Thinkpond](https://thinkpond.jaybulb.com), the idea forum. Built with SwiftUI for iOS 17 and later.

## Features

- Feed of ideas, sorted and filtered, with pull to refresh
- Post detail with votes, threaded comments and App Store matches
- Post your own idea
- Idea Bases: clusters of ideas around one topic
- Sign in with email, or with Apple. The token is kept in the Keychain
- Face ID or Touch ID on iPhone
- Profile with your own ideas

## Run

```bash
cd ios
xcodegen generate
open Spark.xcodeproj
```

The app is part of the Thinkpond repo. The API it calls is described in [docs/API.md](../docs/API.md). The full layout is in [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

## License

MIT 2026 Joshua Trommel
