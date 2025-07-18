import SwiftUI

struct TeamsView: View {
    @StateObject var viewModel: TeamsViewModel
    @State private var newTeamName = ""
    @EnvironmentObject var session: SessionManager
    var onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.teams) { team in
                        NavigationLink(
                            destination: PlayersView(
                                viewModel: PlayersViewModel(teamID: team.id, coachUserID: session.userID ?? "")
                            )
                        ) {
                            Label(team.name, systemImage: "person.3.fill")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color(.systemGroupedBackground))

                HStack(spacing: 12) {
                    TextField("New Team Name", text: $newTeamName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, 8)
                        .accessibilityLabel("New Team Name")
                    Button(action: {
                        Task {
                            await viewModel.addTeam(name: newTeamName)
                            newTeamName = ""
                        }
                    }) {
                        Label("Add", systemImage: "plus")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(newTeamName.isEmpty)
                }
                .padding([.horizontal, .bottom])

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(error)")
                }

                Button(action: {
                    Task {
                        try? await SupabaseService.shared.logoutUser()
                        onLogout()
                    }
                }) {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding([.horizontal, .bottom])
                .accessibilityLabel("Log Out")
            }
            .background(Color(.systemBackground))
            .navigationTitle("Your Teams")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
