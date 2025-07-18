import Foundation

struct PlayerStatInput: Codable, Hashable {
    let player_id: Int
    var points: Int
    var assists: Int
    var rebounds: Int
}



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
        errorMessage = nil
        defer { isLoading = false }
        do {
            players = try await SupabaseService.shared.fetchPlayers(teamID: teamID)
            // Ensure every player has a PlayerStatInput entry in the dictionary
            for player in players {
                if statsByPlayerID[player.id] == nil {
                    statsByPlayerID[player.id] = PlayerStatInput(player_id: player.id, points: 0, assists: 0, rebounds: 0)

                }
            }
        } catch {
            errorMessage = "Failed to load players: \(error.localizedDescription)"
        }
    }

    func submitScorecard() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        // Collect only those with nonzero stats
        let statsArray: [PlayerStatInput] = statsByPlayerID.values
            .filter { $0.points > 0 || $0.assists > 0 || $0.rebounds > 0 }

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
            // Optional: confirm/clear form/etc.
        } catch {
            errorMessage = "Failed to submit scorecard: \(error.localizedDescription)"
        }
    }
}
