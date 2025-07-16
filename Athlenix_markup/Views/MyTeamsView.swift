import SwiftUI

struct MyTeamsView: View {
    let userID: String
    @State private var teams: [Team] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Teams...")
                } else if !teams.isEmpty {
                    List(teams) { team in
                        NavigationLink(destination: PlayersView(viewModel: PlayersViewModel(teamID: team.id))) {
                            Text(team.name)
                        }
                    }
                } else {
                    Text("You are not part of any teams yet.")
                        .foregroundColor(.secondary)
                }

                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("My Teams")
            .task {
                await fetchTeams()
            }
        }
    }

    func fetchTeams() async {
        isLoading = true
        do {
            teams = try await SupabaseService.shared.fetchTeamsForPlayer(userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
