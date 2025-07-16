import Foundation

class StatsViewModel: ObservableObject {
    @Published var stats: [Stat] = []
    @Published var players: [Player] = []      // New property to hold players for the team
    @Published var errorMessage: String?

    let gameID: Int
    let teamID: Int                           // to fetch players for this team

    init(gameID: Int, teamID: Int) {
        self.gameID = gameID
        self.teamID = teamID

        Task {
            await fetchPlayers()
            await fetchStats()
        }
    }

    @MainActor
    func fetchStats() async {
        do {
            stats = try await SupabaseService.shared.fetchStats(forGame: gameID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func fetchPlayers() async {
        do {
            players = try await SupabaseService.shared.fetchPlayers(teamID: teamID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func addStat(playerID: Int, points: Int, assists: Int, rebounds: Int) async {
        do {
            try await SupabaseService.shared.addStat(playerID: playerID, gameID: gameID, points: points, assists: assists, rebounds: rebounds)
            await fetchStats()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
