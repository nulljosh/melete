import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var postToDelete: Post?
    @State private var confirmingDeleteAccount = false
    @State private var serverPosts: [Post]?

    // The feed only holds one page, so your own ideas come from /api/user.
    var myPosts: [Post] {
        guard let username = appState.user?.username else { return [] }
        return serverPosts ?? appState.posts.filter { $0.author?.username == username }
    }

    var body: some View {
        Group {
            if appState.isLoggedIn, let user = appState.user {
                Form {
                    Section {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color.sparkBlue.opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(String(user.username.prefix(1)).uppercased())
                                        .font(.title3.bold())
                                        .foregroundStyle(Color.sparkBlue)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.username)
                                    .font(.headline)
                                Text("\(myPosts.count) idea\(myPosts.count == 1 ? "" : "s")")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Sign Out") { appState.logout() }
                        }
                        .padding(.vertical, 4)
                    }

                    if !myPosts.isEmpty {
                        Section("Your ideas") {
                            ForEach(myPosts) { post in
                                HStack(spacing: 12) {
                                    Text(post.title)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Label("\(post.score)", systemImage: "arrow.up")
                                        .labelStyle(.titleAndIcon)
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                    Button {
                                        postToDelete = post
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Delete idea")
                                }
                            }
                        }
                    }

                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Delete account")
                                Text("Permanently removes your account.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                confirmingDeleteAccount = true
                            } label: {
                                Text("Delete…").foregroundStyle(.red)
                            }
                        }
                    }
                }
                .formStyle(.grouped)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Not signed in")
                        .font(.headline)
                    Button("Sign In / Register") {
                        appState.showAuth = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .tint(.sparkBlue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Profile")
        .task(id: "\(appState.user?.username ?? "")-\(appState.posts.count)") {
            guard let username = appState.user?.username else { serverPosts = nil; return }
            if let posts = try? await appState.api.fetchUserPosts(username: username) {
                serverPosts = posts
            }
        }
        .confirmationDialog(
            "Delete post?",
            isPresented: Binding(
                get: { postToDelete != nil },
                set: { if !$0 { postToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let post = postToDelete else { return }
                Task {
                    do {
                        try await appState.deletePost(id: post.id)
                            serverPosts?.removeAll { $0.id == post.id }
                    } catch {
                        appState.errorBanner = error.localizedDescription
                    }
                }
                postToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                postToDelete = nil
            }
        }
        .confirmationDialog(
            "Delete your account?",
            isPresented: $confirmingDeleteAccount,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task { _ = await appState.deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your account. This cannot be undone.")
        }
    }
}
