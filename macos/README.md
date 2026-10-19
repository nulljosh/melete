![Thinkpond macOS](../icon.svg)

# Thinkpond macOS

![version](https://img.shields.io/badge/version-3.1-blue) ![license](https://img.shields.io/badge/license-MIT-green)

Native Mac app for [Thinkpond](https://thinkpond.jaybulb.com), the idea forum. Built with SwiftUI for macOS 14 and later.

## Features

- Feed of ideas in a sidebar layout, with a detail panel
- Post detail with votes, comments and App Store matches
- Post your own idea
- Idea Bases: clusters of ideas around one topic
- Profile with your own ideas and sign out
- Keyboard shortcuts: Cmd-N for a new post, Cmd-R to refresh, Cmd-Return to submit
- Dark and light mode follow the system

## Build

```bash
cd macos
xcodegen generate
open SparkMac.xcodeproj
```

The API it calls is described in [docs/API.md](../docs/API.md). The full layout is in [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

## License

MIT 2026, Joshua Trommel
