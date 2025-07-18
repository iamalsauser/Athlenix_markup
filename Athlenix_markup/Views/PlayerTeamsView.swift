//
//  PlayerTeamsView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import SwiftUI

struct PlayerTeamsView: View {
    let userID: String
    @StateObject private var viewModel = PlayerTeamsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading your teams...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if !viewModel.teams.isEmpty {
                    List(viewModel.teams) { team in
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
                    Text("You are not part of any team yet.")
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .padding()
                }

                if let error = viewModel.errorMessage {
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
                await viewModel.fetchTeams(for: userID)
            }
        }
    }
}
