import SwiftUI

struct ScorecardApprovalView: View {
    @StateObject var viewModel: ScorecardApprovalViewModel
    @State private var selectedScorecardID: Int?
    @State private var showStatsSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading pending scorecards...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if viewModel.scorecards.isEmpty {
                    Text("No pending scorecards for approval")
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .padding()
                } else {
                    List(viewModel.scorecards) { scorecard in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(scorecard.opponent)
                                    .font(.headline)
                                Text("Game Date: \(formattedDate(scorecard.game_date))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Created At: \(formattedDate(scorecard.created_at))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                Task {
                                    selectedScorecardID = scorecard.id
                                    await viewModel.fetchStats(forScorecard: scorecard.id)
                                    showStatsSheet = true
                                }
                            }) {
                                Label("View Stats", systemImage: "list.bullet.rectangle")
                            }
                            .buttonStyle(.bordered)
                            Button(action: {
                                Task {
                                    await viewModel.approve(scorecardID: scorecard.id)
                                }
                            }) {
                                Label("Approve", systemImage: "checkmark")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            Button(action: {
                                Task {
                                    await viewModel.reject(scorecardID: scorecard.id)
                                }
                            }) {
                                Label("Reject", systemImage: "xmark")
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))
                }
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(error)")
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Scorecard Approval")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showStatsSheet) {
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
