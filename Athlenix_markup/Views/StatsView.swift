import SwiftUI

struct StatsView: View {
    @StateObject var viewModel: StatsViewModel
    @State private var selectedPlayerID: Int? = nil

    @State private var points = ""
    @State private var assists = ""
    @State private var rebounds = ""

    var body: some View {
        VStack {
            List(viewModel.stats) { stat in
                VStack(alignment: .leading) {
                    Text("Player ID: \(stat.player_id)")
                        .bold()
                    HStack {
                        Text("🏀 Points: \(stat.points)")
                        Text("🎯 Assists: \(stat.assists)")
                        Text("🛡 Rebounds: \(stat.rebounds)")
                    }
                }
            }

            VStack(spacing: 10) {
                // Picker for selecting player
                Picker("Select Player", selection: $selectedPlayerID) {
                    Text("Select a Player").tag(Int?.none)
                    ForEach(viewModel.players) { player in
                        Text("\(player.name) #\(player.number ?? 0)")
                            .tag(Optional(player.id))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                TextField("Points", text: $points)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Assists", text: $assists)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Rebounds", text: $rebounds)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Add Stat") {
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
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedPlayerID == nil)
            }
            .padding()

            if let error = viewModel.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Stats")
    }

    private func clearFields() {
        selectedPlayerID = nil
        points = ""
        assists = ""
        rebounds = ""
    }
}
