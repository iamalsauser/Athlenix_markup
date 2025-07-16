//
//  LiveScoreViewModel.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import Foundation

@MainActor
class LiveScoreViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var statsByPlayerID: [Int: PlayerStatInput] = [:]
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isSubmitting = false

    let gameID: Int
    let coachID: String
    let teamID: Int

    init(gameID: Int, coachID: String, teamID: Int) {
        self.gameID = gameID
        self.coachID = coachID
        self.teamID = teamID
    }

    func fetchPlayers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            players = try await SupabaseService.shared.fetchPlayers(teamID: teamID)
            // Initialize statsByPlayerID dictionary
            for player in players {
                statsByPlayerID[player.id] = PlayerStatInput()
            }
        } catch {
            errorMessage = "Failed to load players: \(error.localizedDescription)"
        }
    }

    func submitScorecard() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        // Prepare stats array as dictionary for JSON conversion
        let statsArray: [[String: Any]] = statsByPlayerID.compactMap { (playerID, input) in
            // Only submit players with any non-zero stats
            if input.points == 0 && input.assists == 0 && input.rebounds == 0 { return nil }
            return [
                "player_id": playerID,
                "points": input.points,
                "assists": input.assists,
                "rebounds": input.rebounds
            ]
        }

        if statsArray.isEmpty {
            errorMessage = "Please enter stats for at least one player before submitting."
            return
        }

        do {
            _ = try await SupabaseService.shared.insertScorecardWithStats(
                gameID: gameID,
                coachID: coachID,
                stats: statsArray
            )
            // Success: You can navigate or show confirmation
        } catch {
            errorMessage = "Failed to submit scorecard: \(error.localizedDescription)"
        }
    }
}

// Helper structure to store inputs for each player’s stats
struct PlayerStatInput {
    var points: Int = 0
    var assists: Int = 0
    var rebounds: Int = 0
}
