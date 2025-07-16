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
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading your teams...")
                } else if !viewModel.teams.isEmpty {
                    List(viewModel.teams) { team in
                        NavigationLink(destination: PlayersView(viewModel: PlayersViewModel(teamID: team.id))) {
                            Text(team.name)
                        }
                    }
                } else {
                    Text("You are not part of any team yet.")
                        .foregroundColor(.secondary)
                }

                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("My Teams")
            .task {
                await viewModel.fetchTeams(for: userID)
            }
        }
    }
}
