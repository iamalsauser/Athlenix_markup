import SwiftUI

struct LiveScoreView: View {
    @StateObject var viewModel: LiveScoreViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading players...")
                } else {
                    List {
                        ForEach(viewModel.players) { player in
                            VStack(alignment: .leading) {
                                Text(player.name)
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    StatStepper(label: "Points", value: Binding(
                                        get: { viewModel.statsByPlayerID[player.id]?.points ?? 0 },
                                        set: { newValue in
                                            var current = viewModel.statsByPlayerID[player.id] ?? PlayerStatInput()
                                            current.points = newValue
                                            viewModel.statsByPlayerID[player.id] = current
                                        }
                                    ))
                                    StatStepper(label: "Assists", value: Binding(
                                        get: { viewModel.statsByPlayerID[player.id]?.assists ?? 0 },
                                        set: { newValue in
                                            var current = viewModel.statsByPlayerID[player.id] ?? PlayerStatInput()
                                            current.assists = newValue
                                            viewModel.statsByPlayerID[player.id] = current
                                        }
                                    ))
                                    StatStepper(label: "Rebounds", value: Binding(
                                        get: { viewModel.statsByPlayerID[player.id]?.rebounds ?? 0 },
                                        set: { newValue in
                                            var current = viewModel.statsByPlayerID[player.id] ?? PlayerStatInput()
                                            current.rebounds = newValue
                                            viewModel.statsByPlayerID[player.id] = current
                                        }
                                    ))
                                }
                            }
                            .padding(.vertical, 6)
                        }

                    }
                    .listStyle(.plain)

                    Button(action: {
                        Task { await viewModel.submitScorecard() }
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Submit Scorecard")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.isSubmitting)
                    .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Live Scoring")
            .task { await viewModel.fetchPlayers() }
        }
    }
}

struct StatStepper: View {
    let label: String
    @Binding var value: Int
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
            Stepper(value: $value, in: 0...200) {
                Text("\(value)")
                    .frame(width: 36)
            }.labelsHidden()
        }
    }
}
