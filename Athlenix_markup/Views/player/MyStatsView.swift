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
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading your stats...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if !stats.isEmpty {
                    List(stats) { stat in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Game vs \(stat.opponentName)")
                                .font(.headline)
                            HStack(spacing: 16) {
                                Text("🏀 Points: \(stat.points)")
                                Text("🎯 Assists: \(stat.assists)")
                                Text("🛡️ Rebounds: \(stat.rebounds)")
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))
                } else {
                    Text("No stats available yet.")
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
            .navigationTitle("My Stats")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadStats()
            }
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
