import SwiftUI
import Foundation

struct PlayersView: View {
    @StateObject var viewModel: PlayersViewModel
    @State private var selectedUser: Profile?
    @State private var jerseyNumber = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.profiles, id: \ .id) { profile in
                        let player = viewModel.players.first { $0.user_id == profile.id }
                        HStack {
                            VStack(alignment: .leading) {
                                Text(profile.display_name ?? "Unnamed")
                                    .font(.headline)
                                if let player = player, let number = player.number {
                                    Text("Jersey: #\(number)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Not on team")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            if let player = player {
                                NavigationLink(destination: PlayerProfileView(userID: player.user_id ?? "")) {
                                    Label("View", systemImage: "person.fill")
                                }
                            } else {
                                Button(action: {
                                    selectedUser = profile
                                }) {
                                    Label("Add", systemImage: "plus")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color(.systemGroupedBackground))

                if let selectedUser = selectedUser {
                    VStack(spacing: 12) {
                        Text("Add \(selectedUser.display_name ?? "Unnamed") to team")
                            .font(.headline)
                        TextField("Jersey Number", text: $jerseyNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .accessibilityLabel("Jersey Number")
                        Button(action: {
                            if let number = Int(jerseyNumber) {
                                Task {
                                    await viewModel.addPlayer(from: selectedUser, number: number)
                                    jerseyNumber = ""
                                    self.selectedUser = nil
                                }
                            }
                        }) {
                            Label("Add Player", systemImage: "plus")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(jerseyNumber.isEmpty)
                        .padding(.horizontal)
                        Button("Cancel") {
                            self.selectedUser = nil
                            jerseyNumber = ""
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.vertical)
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                    .padding([.horizontal, .bottom])
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
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: GamesView(
                            viewModel: GamesViewModel(teamID: viewModel.teamID),
                            coachUserID: viewModel.coachUserID
                        )
                    ) {
                        Label("Games", systemImage: "calendar")
                    }
                }
            }
        }
    }
}
