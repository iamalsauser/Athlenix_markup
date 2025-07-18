//
//  MyGamesView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import SwiftUI

struct MyGamesView: View {
    let userID: String
    @State private var games: [GameDetail] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOnlyUpcoming = true

    var sortedGames: [GameDetail] {
        games.sorted { $0.date < $1.date }
    }

    var filteredGames: [GameDetail] {
        sortedGames.filter { game in
            guard let gDate = ISO8601DateFormatter().date(from: game.date) else { return false }
            return showOnlyUpcoming ? gDate >= Date() : true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Toggle("Show only upcoming games", isOn: $showOnlyUpcoming)
                    .padding([.top, .horizontal])

                if isLoading {
                    ProgressView("Loading your games...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if !filteredGames.isEmpty {
                    List(filteredGames) { game in
                        let isUpcoming = (ISO8601DateFormatter().date(from: game.date) ?? Date()) >= Date()
                        NavigationLink(
                            destination: PlayerGameStatsView(gameID: game.id, userID: userID)
                        ) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("🏀 Opponent: \(game.opponent)")
                                    .foregroundColor(isUpcoming ? .green : .gray)
                                    .font(.headline)
                                Text("📅 Date: \(formattedDate(game.date))")
                                    .fontWeight(isUpcoming ? .bold : .regular)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))
                } else {
                    Text("No games found.")
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
            .navigationTitle("My Games")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadGames()
            }
        }
    }

    func formattedDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return isoDate
    }

    func loadGames() async {
        isLoading = true
        do {
            games = try await SupabaseService.shared.fetchGamesForPlayer(userID: userID)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            games = []
        }
        isLoading = false
    }
}
