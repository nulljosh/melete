# Melete macOS
v3.1
## Rules
- macOS 14+, SwiftUI, @Observable
- Sidebar navigation: Feed, Create, Profile
- Accent: laurel green #4d7c45 (#8fc286 dark), same palette as iOS
- No emojis
- Keyboard shortcuts: Cmd-N (new post), Cmd-R (refresh), Cmd-Return (submit post)
- Error banner system for auth and API failures
- Optimistic voting with debounce and error revert
- Same API as iOS: https://melete.jaybulb.com
## Run
```bash
cd macos && xcodegen generate && open SparkMac.xcodeproj
xcodebuild -scheme SparkMac -destination 'platform=macOS' build
```
## Key Files
- SparkApp.swift: App entry point, WindowGroup, menu commands
- ContentView.swift: Sidebar navigation (Feed/Create/Profile), error banner
- Models/AppState.swift: Observable app state for auth, posts, voting
- API/SparkAPI.swift: HTTP client for Spark APIs, JWT token via Keychain
- Views/FeedView.swift: Post list with one New/Trending switch
- Views/PostDetailView.swift: Title, pitch, votes, closest App Store apps, comments; delete and share
- Views/CreateView.swift: Title and description; every post gets its write-up
- Views/ProfileView.swift: User profile, own posts, logout
- Views/AuthSheet.swift: Login/register sheet
