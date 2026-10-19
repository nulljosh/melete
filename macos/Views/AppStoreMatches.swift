import SwiftUI

/// "Already on the App Store": the top three apps Apple's public search returns for
/// an idea's title. Called from the device, never our server (Apple rate-limits
/// Cloudflare's shared IPs). Says it is checking while it waits, and disappears on error.
/// The waiting line matters: an empty view never appears, so its .task would never run.
struct AppStoreMatches: View {
    let query: String
    @State private var apps: [Match]?
    @State private var failed = false

    struct Match: Decodable, Identifiable {
        let trackId: Int
        let trackName: String
        let sellerName: String
        let trackViewUrl: URL
        let averageUserRating: Double?
        let userRatingCount: Int?
        var id: Int { trackId }
    }

    var body: some View {
        Group {
            if failed {
                EmptyView()
            } else if apps == nil {
                Text("Checking the App Store...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let apps {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ALREADY ON THE APP STORE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    if apps.isEmpty {
                        Text("Nothing close. Open water.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(apps) { app in
                        Link(destination: app.trackViewUrl) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(app.trackName).font(.callout.weight(.medium)).foregroundStyle(.primary)
                                    Text(app.sellerName).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let r = app.averageUserRating {
                                    Text("\(r, specifier: "%.1f") (\(app.userRatingCount ?? 0))")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task(id: query) {
            apps = await Self.search(query)
            failed = apps == nil
        }
    }

    static func search(_ term: String) async -> [Match]? {
        var c = URLComponents(string: "https://itunes.apple.com/search")!
        c.queryItems = [.init(name: "entity", value: "software"), .init(name: "country", value: "us"),
                        .init(name: "limit", value: "3"), .init(name: "term", value: term)]
        struct Response: Decodable { let results: [Match] }
        guard let url = c.url, let (data, _) = try? await URLSession.shared.data(from: url),
              let r = try? JSONDecoder().decode(Response.self, from: data) else { return nil }
        return r.results
    }
}
