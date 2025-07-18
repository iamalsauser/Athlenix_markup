import SwiftUI

struct MyTeamsView: View {
    let userID: String
    @State private var teams: [Team] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading Teams...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if !teams.isEmpty {
                    List(teams) { team in
                        NavigationLink(
                            destination: PlayersView(
                                viewModel: PlayersViewModel(teamID: team.id, coachUserID: userID)
                            )
                        ) {
                            Label(team.name, systemImage: "person.3.fill")
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))
                } else {
                    Text("You are not part of any teams yet.")
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .padding()
                }

                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(error)")
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("My Teams")
            .navigationBarTitleDisplayMode(.inline)
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
