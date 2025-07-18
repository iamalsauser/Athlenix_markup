import SwiftUI

struct StatsView: View {
    @StateObject var viewModel: StatsViewModel
    @State private var selectedPlayerID: Int? = nil
    @State private var points = ""
    @State private var assists = ""
    @State private var rebounds = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(viewModel.stats) { stat in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Player ID: \(stat.player_id)")
                            .font(.headline)
                        HStack(spacing: 16) {
                            Text("🏀 Points: \(stat.points)")
                            Text("🎯 Assists: \(stat.assists)")
                            Text("🛡 Rebounds: \(stat.rebounds)")
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
                .background(Color(.systemGroupedBackground))

                Form {
                    Section(header: Text("Add Stat")) {
                        Picker("Select Player", selection: $selectedPlayerID) {
                            Text("Select a Player").tag(Int?.none)
                            ForEach(viewModel.players) { player in
                                Text("\(player.name) #\(player.number ?? 0)")
                                    .tag(Optional(player.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityLabel("Select Player")

                        TextField("Points", text: $points)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Points")
                        TextField("Assists", text: $assists)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Assists")
                        TextField("Rebounds", text: $rebounds)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Rebounds")

                        Button(action: {
                            guard let playerID = selectedPlayerID,
                                  let pointsInt = Int(points),
                                  let assistsInt = Int(assists),
                                  let reboundsInt = Int(rebounds) else {
                                viewModel.errorMessage = "Please fill all fields correctly."
                                return
                            }
                            Task {
                                await viewModel.addStat(playerID: playerID, points: pointsInt, assists: assistsInt, rebounds: reboundsInt)
                                clearFields()
                            }
                        }) {
                            Label("Add Stat", systemImage: "plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(selectedPlayerID == nil)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemBackground))
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.bottom)
            .toolbar { }
            if let error = viewModel.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
                    .accessibilityLabel("Error: \(error)")
            }
        }
    }

    private func clearFields() {
        selectedPlayerID = nil
        points = ""
        assists = ""
        rebounds = ""
    }
}
