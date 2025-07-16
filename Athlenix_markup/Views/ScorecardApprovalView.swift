import SwiftUI

struct ScorecardApprovalView: View {
    @StateObject var viewModel: ScorecardApprovalViewModel
    @State private var selectedScorecardID: Int?
    @State private var showStatsSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading pending scorecards...")
                } else if viewModel.scorecards.isEmpty {
                    Text("No pending scorecards for approval")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.scorecards) { scorecard in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Opponent: \(scorecard.opponent)")
                                    .font(.headline)
                                Text("Game Date: \(formattedDate(scorecard.game_date))")
                                    .font(.subheadline)
                                Text("Created At: \(formattedDate(scorecard.created_at))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button("View Stats") {
                                Task {
                                    selectedScorecardID = scorecard.id
                                    await viewModel.fetchStats(forScorecard: scorecard.id)
                                    showStatsSheet = true
                                }
                            }
                            .buttonStyle(.bordered)

                            Button("Approve") {
                                Task {
                                    await viewModel.approve(scorecardID: scorecard.id)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)

                            Button("Reject") {
                                Task {
                                    await viewModel.reject(scorecardID: scorecard.id)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.vertical, 4)
                    }
                }

                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Scorecard Approval")
            .sheet(isPresented: $showStatsSheet) {
                // Just return the view directly here; don't conditionally return nil
                ScorecardStatsView(stats: viewModel.selectedScorecardStats)
            }
            .task {
                await viewModel.fetchPendingScorecards()
            }
        }
    }

    func formattedDate(_ isoDateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return isoDateString
    }
}
