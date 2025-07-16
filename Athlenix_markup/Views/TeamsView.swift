import SwiftUI

struct TeamsView: View {
    @StateObject var viewModel: TeamsViewModel
    @State private var newTeamName = ""
    var onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.teams) { team in
                    NavigationLink(destination: PlayersView(viewModel: PlayersViewModel(teamID: team.id))) {
                        Text(team.name)
                    }
                }

                HStack {
                    TextField("New Team Name", text: $newTeamName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        Task {
                            await viewModel.addTeam(name: newTeamName)
                            newTeamName = ""
                        }
                    }
                    .disabled(newTeamName.isEmpty)
                }
                .padding()

                if viewModel.isLoading {
                    ProgressView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Spacer()

                Button("Log Out") {
                    Task {
                        try? await SupabaseService.shared.logoutUser()
                        onLogout()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Your Teams")
        }
    }
}
