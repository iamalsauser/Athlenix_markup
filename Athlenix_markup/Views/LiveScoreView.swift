import SwiftUI

struct LiveScoreView: View {
    @StateObject var viewModel: LiveScoreViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading players...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.players) { player in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(player.name)
                                    .font(.headline)
                                    .accessibilityAddTraits(.isHeader)
                                HStack(spacing: 16) {
                                    StatStepper(
                                        label: "Points",
                                        value: statBinding(for: player.id, \PlayerStatInput.points)
                                    )
                                    StatStepper(
                                        label: "Assists",
                                        value: statBinding(for: player.id, \PlayerStatInput.assists)
                                    )
                                    StatStepper(
                                        label: "Rebounds",
                                        value: statBinding(for: player.id, \PlayerStatInput.rebounds)
                                    )
                                }
                                .padding(.top, 2)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))

                    Button(action: {
                        Task { await viewModel.submitScorecard() }
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Submit Scorecard")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(viewModel.isSubmitting)
                    .padding([.horizontal, .bottom])
                    .accessibilityLabel("Submit Scorecard")
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(error)")
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Live Scoring")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.fetchPlayers() }
        }
    }

    // Helper function to create a binding for a PlayerStatInput field/keyPath
    private func statBinding(for playerID: Int, _ keyPath: WritableKeyPath<PlayerStatInput, Int>) -> Binding<Int> {
        Binding<Int>(
            get: {
                viewModel.statsByPlayerID[playerID]?[keyPath: keyPath] ?? 0
            },
            set: { newValue in
                var current = viewModel.statsByPlayerID[playerID] ?? PlayerStatInput(player_id: playerID, points: 0, assists: 0, rebounds: 0)
                current[keyPath: keyPath] = newValue
                viewModel.statsByPlayerID[playerID] = current
            }
        )
    }
}

struct StatStepper: View {
    let label: String
    @Binding var value: Int
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Stepper(value: $value, in: 0...200) {
                Text("\(value)")
                    .frame(width: 36)
                    .font(.body.monospacedDigit())
                    .accessibilityLabel("\(label): \(value)")
            }
            .labelsHidden()
        }
        .frame(minWidth: 70)
    }
}
