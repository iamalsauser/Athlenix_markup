import SwiftUI
import Foundation

struct PlayersView: View {
    @StateObject var viewModel: PlayersViewModel
    @State private var selectedUser: Profile?
    @State private var jerseyNumber = ""

    var body: some View {
        VStack {
            // Player List
            List(viewModel.players) { player in
                NavigationLink(destination: PlayerProfileView(userID: player.user_id ?? "")) {
                    Text("\(player.name)  #\(player.number ?? 0)")
                }
            }

            // Add Player Area
            VStack(spacing: 10) {
                // User Picker
                Picker("Select a user", selection: $selectedUser) {
                    ForEach(viewModel.profiles, id: \.id) { profile in
                        Text(profile.display_name ?? "Unnamed")
                            .tag(profile as Profile?)
                    }
                }
                .pickerStyle(.wheel)

                // Jersey Number Field
                TextField("Jersey Number", text: $jerseyNumber)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke())

                // Add Button
                Button("Add Player") {
                    if let profile = selectedUser,
                       let number = Int(jerseyNumber) {
                        Task {
                            await viewModel.addPlayer(from: profile, number: number)
                            jerseyNumber = ""
                            selectedUser = nil
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
            .padding()

            // Errors
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .navigationTitle("Players")
        .navigationBarItems(trailing:
            NavigationLink(destination: GamesView(viewModel: GamesViewModel(teamID: viewModel.teamID))) {
                Text("Games")
            }
        )
    }
}
