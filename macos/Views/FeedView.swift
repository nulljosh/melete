import SwiftUI

enum SortMode: String, CaseIterable {
    case new = "New"
    case hot = "Trending"
}

struct FeedView: View {
    @Environment(AppState.self) private var appState
    @State private var sortMode: SortMode = .new
    @State private var selectedPost: Post?

    private var filteredPosts: [Post] {
        switch sortMode {
        case .hot:
            return appState.posts // API default sort
        case .new:
            return appState.posts.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        }
    }

    var body: some View {
        // ponytail: HSplitView, not a second NavigationSplitView -- this whole view sits
        // inside ContentView's split detail column, and nesting two of them makes each
        // claim its own ideal column widths. Their sum exceeds the window, so AppKit
        // squeezes the outer sidebar and pushes the detail past the right edge (the
        // "layout of the main window is not sized fitted" 2.1(a) rejection, 2026-08-24).
        HSplitView {
            VStack(spacing: 0) {
                // Toolbar bar
                HStack(spacing: 8) {
                    Picker("Sort", selection: $sortMode) {
                        ForEach(SortMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 120)

                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()

                if appState.isFeedLoading && appState.posts.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading posts...")
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else if appState.posts.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "flame")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No posts yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Be the first to share an idea.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List(filteredPosts, selection: $selectedPost) { post in
                        PostRow(post: post)
                            .tag(post)
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                    // Open on the top idea rather than an empty pane. Every Mac
                    // split-view app does this, and a third of the window reading
                    // "Select a post" is a poor first impression. Only fills an
                    // empty selection, so it never fights the user's own choice.
                    .onChange(of: filteredPosts) { _, posts in
                        if selectedPost == nil { selectedPost = posts.first }
                    }
                    .onAppear {
                        if selectedPost == nil { selectedPost = filteredPosts.first }
                    }
                }
            }
            // Max plus the detail's 320 must stay within the detail column's 640 minimum,
            // or the detail pane runs past the window edge at small sizes.
            .frame(minWidth: 260, idealWidth: 300, maxWidth: 320)

            Group {
                if let post = selectedPost {
                    PostDetailView(post: post)
                } else {
                    Text("Select a post")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Thinkpond")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task { await appState.loadPosts() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh (Cmd-R)")
            }
            ToolbarItem(placement: .automatic) {
                if appState.isLoggedIn {
                    Button {
                        appState.logout()
                    } label: {
                        Image(systemName: "person.fill.checkmark")
                            .foregroundStyle(Color.sparkBlue)
                    }
                    .help("Signed in as \(appState.user?.username ?? "")")
                } else {
                    Button("Sign In") {
                        appState.showAuth = true
                    }
                    .tint(.sparkBlue)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFeed)) { _ in
            Task { await appState.loadPosts() }
        }
        .task { await appState.loadPosts() }
    }
}

// MARK: - Post Row

struct PostRow: View {
    @Environment(AppState.self) private var appState
    let post: Post

    private var currentPost: Post {
        appState.posts.first(where: { $0.id == post.id }) ?? post
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(currentPost.title)
                .font(.headline)
                .lineLimit(2)

            Text(currentPost.content ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 10) {
                VoteButton(label: "up", icon: "arrow.up", postId: currentPost.id)
                Text("\(currentPost.score)")
                    .font(.subheadline.monospacedDigit())
                    .contentTransition(.numericText(value: Double(currentPost.score)))
                    .animation(.spring(duration: 0.3), value: currentPost.score)
                VoteButton(label: "down", icon: "arrow.down", postId: currentPost.id)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Vote Button

struct VoteButton: View {
    @Environment(AppState.self) private var appState
    let label: String
    let icon: String
    let postId: String

    private var isVoting: Bool {
        appState.votingPostIds.contains(postId)
    }

    // Lit when this is the way you voted.
    private var isMine: Bool {
        let mine = appState.posts.first(where: { $0.id == postId })?.myVote ?? 0
        return mine == (label == "up" ? 1 : -1)
    }

    var body: some View {
        Button {
            Task { await appState.vote(postId: postId, type: label) }
        } label: {
            Image(systemName: isMine ? "\(icon).circle.fill" : icon)
                .font(isMine ? .body : .subheadline)
                .foregroundStyle(appState.isLoggedIn ? Color.sparkBlue : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        .disabled(!appState.isLoggedIn || isVoting)
    }
}
