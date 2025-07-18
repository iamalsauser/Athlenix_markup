import SwiftUI

struct GamesView: View {
    @StateObject var viewModel: GamesViewModel
    let coachUserID: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(viewModel.games) { game in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(game.opponent)
                            .font(.headline)
                        Text(formattedDate(game.game_date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        NavigationLink(
                            destination: LiveScoreView(
                                viewModel: LiveScoreViewModel(
                                    gameID: game.id,
                                    coachID: coachUserID,
                                    teamID: game.team_id
                                )
                            )
                        ) {
                            Label("Start Live Scoring", systemImage: "pencil.and.outline")
                                .font(.callout)
                                .padding(6)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(.insetGrouped)
                .background(Color(.systemGroupedBackground))

                if let error = viewModel.errorMessage {
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(error)")
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formattedDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return isoDate
    }
}
