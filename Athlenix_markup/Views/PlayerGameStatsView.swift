//
//  PlayerGameStatsView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import SwiftUI

struct PlayerGameStatsView: View {
    let gameID: Int
    let userID: String
    @State private var stats: [Stat] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var playerIntID: Int?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if !stats.isEmpty {
                    List(stats) { stat in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Points: \(stat.points)")
                                .font(.headline)
                            Text("Assists: \(stat.assists)")
                                .font(.subheadline)
                            Text("Rebounds: \(stat.rebounds)")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))
                } else {
                    Text("No stats for this game.")
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
            .navigationTitle("Game Stats")
            .navigationBarTitleDisplayMode(.inline)
            .task { await fetchStats() }
        }
    }

    func fetchStats() async {
        isLoading = true
        do {
            if playerIntID == nil {
                playerIntID = try await SupabaseService.shared.fetchPlayerID(forUserID: userID)
            }

            guard let pid = playerIntID else {
                errorMessage = "Player record not found"
                isLoading = false
                return
            }

            let allStats = try await SupabaseService.shared.fetchStats(forGame: gameID)
            stats = allStats.filter { $0.player_id == pid }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
