import Foundation
import Supabase

class GamesViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var errorMessage: String?
    let teamID: Int

    init(teamID: Int) {
        self.teamID = teamID
        Task { await fetch() }
    }

    @MainActor
    func fetch() async {
        do {
            games = try await SupabaseService.shared.fetchGames(teamID: teamID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func addGame(opponent: String, date: String) async {
        do {
            try await SupabaseService.shared.addGame(opponent: opponent, date: date, teamID: teamID)
            await fetch()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // GamesViewModel.swift
    func fetchPlayers(forTeam teamID: Int) async throws -> [Player] {
        let response: PostgrestResponse<[Player]> = try await SupabaseService.shared.client
            .from("players")
            .select()
            .eq("team_id", value: teamID)
            .execute()
        return response.value
    }

}
