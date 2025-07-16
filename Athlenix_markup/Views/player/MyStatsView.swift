//
//  MyStatsView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import SwiftUI

struct MyStatsView: View {
    let userID: String
    @State private var stats: [StatDetail] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading your stats...")
            } else if !stats.isEmpty {
                List(stats) { stat in
                    VStack(alignment: .leading) {
                        Text("Game vs \(stat.opponentName)")
                            .font(.headline)

                        HStack {
                            Text("🏀 Points: \(stat.points)")
                            Text("🎯 Assists: \(stat.assists)")
                            Text("🛡️ Rebounds: \(stat.rebounds)")
                        }
                        .font(.subheadline)
                    }
                }
            } else {
                Text("No stats available yet.")
            }
            

            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("My Stats")
        .task {
            await loadStats()
        }
    }

    func loadStats() async {
        isLoading = true
        do {
            stats = try await SupabaseService.shared.fetchStatsForPlayer(userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
