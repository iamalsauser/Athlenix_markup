//
// SupabaseService.swift
// Athlinix
//

import Foundation
import Supabase

struct InsertScorecardParams: Encodable {
    let p_game_id: Int
    let p_coach_id: String
    let p_stats: [PlayerStatInput]
}



class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    // MARK: - Initialization

    private init() {
        let url = URL(string: "https://nfapapiyexhgaokjwblx.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5mYXBhcGl5ZXhoZ2Fva2p3Ymx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NjExMTAsImV4cCI6MjA2ODIzNzExMH0.daJ4W4OA4uUhFObUT6JKTB7Nxcl__nADiqvhKMLL9Kg"
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }

    // MARK: - Teams

    func fetchTeams(for userID: String) async throws -> [Team] {
        let response: PostgrestResponse<[Team]> = try await client
            .from("teams")
            .select()
            .eq("coach_user_id", value: userID)
            .execute()
        return response.value
    }

    func addTeam(name: String, coachUserID: String) async throws {
        let newTeam = NewTeam(name: name, coach_user_id: coachUserID)
        _ = try await client
            .from("teams")
            .insert(newTeam)
            .execute()
    }

    // MARK: - Players

    func fetchPlayers(teamID: Int) async throws -> [Player] {
            let response: PostgrestResponse<[Player]> = try await client
                .from("players")
                .select()
                .eq("team_id", value: teamID)
                .execute()
            return response.value
        }

    func addPlayer(name: String, number: Int, teamID: Int, userID: String) async throws {
        let newPlayer = NewPlayerWithUser(name: name, number: number, team_id: teamID, user_id: userID)
        _ = try await client
            .from("players")
            .insert(newPlayer)
            .execute()
    }

    // MARK: - Games

    func fetchGames(teamID: Int) async throws -> [Game] {
        let response: PostgrestResponse<[Game]> = try await client
            .from("games")
            .select()
            .eq("team_id", value: teamID)
            .execute()
        return response.value
    }

    func addGame(opponent: String, date: String, teamID: Int) async throws {
        let newGame = NewGame(opponent: opponent, game_date: date, team_id: teamID)
        _ = try await client
            .from("games")
            .insert(newGame)
            .execute()
    }

    // MARK: - Stats

    func fetchStats(forGame gameID: Int) async throws -> [Stat] {
        let response: PostgrestResponse<[Stat]> = try await client
            .from("stats")
            .select()
            .eq("game_id", value: gameID)
            .execute()
        return response.value
    }

    func addStat(playerID: Int, gameID: Int, points: Int, assists: Int, rebounds: Int) async throws {
        let newStat = NewStat(
            player_id: playerID,
            game_id: gameID,
            points: points,
            assists: assists,
            rebounds: rebounds
        )
        _ = try await client
            .from("stats")
            .insert(newStat)
            .execute()
    }

    // MARK: - Profiles (User)

    func createProfile(userID: UUID, displayName: String) async throws {
        let profile = NewProfile(id: userID.uuidString, display_name: displayName)
        _ = try await client
            .from("profiles")
            .insert(profile)
            .execute()
    }

    func fetchAllProfiles() async throws -> [Profile] {
        let response: PostgrestResponse<[Profile]> = try await client
            .from("profiles")
            .select()
            .execute()
        return response.value
    }

    func fetchProfile(userID: String) async throws -> Profile? {
        let response: PostgrestResponse<[Profile]> = try await client
            .from("profiles")
            .select()
            .eq("id", value: userID)
            .limit(1)
            .execute()
        return response.value.first
    }
    
    // MARK: - Auth

    func logoutUser() async throws {
        try await client.auth.signOut()
    }
    
    func isUserPlayer(_ userID: String) async throws -> Bool {
        let response: PostgrestResponse<[Player]> = try await client
            .from("players")
            .select()
            .eq("user_id", value: userID)
            .limit(1)
            .execute()
        return !response.value.isEmpty
    }

    func fetchStatsForPlayer(userID: String) async throws -> [StatDetail] {
        let response: PostgrestResponse<[StatDetail]> = try await client
            .from("stats_with_games")
            .select()
            .eq("user_id", value: userID)
            .execute()
        return response.value
    }

    func fetchGamesForPlayer(userID: String) async throws -> [GameDetail] {
        let response: PostgrestResponse<[GameDetail]> = try await client
            .from("games_for_player")
            .select()
            .execute()
        return response.value
    }

    func fetchTeamsForPlayer(userID: String) async throws -> [Team] {
        let response: PostgrestResponse<[Team]> = try await client
            .from("teams_for_player")
            .select()
            .execute()
        return response.value
    }
    
    

    func fetchPlayerID(forUserID userID: String) async throws -> Int? {
        let response: PostgrestResponse<[Player]> = try await client
            .from("players")
            .select("id")
            .eq("user_id", value: userID)
            .limit(1)
            .execute()

        return response.value.first?.id
    }

    func createProfile(userID: UUID, displayName: String, role: String) async throws {
        let profile = ["id": userID.uuidString, "display_name": displayName, "role": role]
        _ = try await client
            .from("profiles")
            .insert(profile)
            .execute()
    }

    func getUserRole(userID: String) async throws -> String? {
        let response: PostgrestResponse<[Profile]> = try await client
            .from("profiles")
            .select("id, role")
            .eq("id", value: userID)
            .limit(1)
            .execute()

        return response.value.first?.role
    }
    
    // MARK: - Scorecards (New for live match scoring)

    // Insert a new scorecard with player stats (calls insert_scorecard_with_stats RPC)
    // Pass [PlayerStatInput] directly to the RPC as the params for p_stats
    func insertScorecardWithStats(gameID: Int, coachID: String, stats: [PlayerStatInput]) async throws -> Int {
        let params = InsertScorecardParams(
            p_game_id: gameID,
            p_coach_id: coachID,
            p_stats: stats
        )
        let response: PostgrestResponse<[ScorecardIDResponse]> = try await client
            .rpc("insert_scorecard_with_stats", params: params)
            .execute()

        guard let idString = response.value.first?.id, let id = Int(idString) else {
            throw NSError(domain: "Failed to get scorecard ID", code: 0)
        }
        return id
    }




    // Approve a scorecard
    func approveScorecard(scorecardID: Int) async throws {
        _ = try await client.rpc("approve_scorecard", params: ["p_scorecard_id": scorecardID]).execute()
    }

    // Reject a scorecard
    func rejectScorecard(scorecardID: Int) async throws {
        _ = try await client.rpc("reject_scorecard", params: ["p_scorecard_id": scorecardID]).execute()
    }
    
    // Represents a basic Scorecard info with game details for list
    

}

// Helper struct to decode scorecard insertion response
struct ScorecardIDResponse: Codable {
    let id: String
}


struct PendingScorecard: Identifiable, Codable {
    let id: Int
    let game_id: Int
    let coach_id: String
    let status: String
    let created_at: String
    let opponent: String
    let game_date: String
}

extension SupabaseService {
    func fetchPendingScorecards(coachID: String) async throws -> [PendingScorecard] {
        let response: PostgrestResponse<[PendingScorecard]> = try await client
            .from("scorecards")
            .select("""
                id, game_id, coach_id, status, created_at,
                games!inner(opponent, game_date)
                """)
            .eq("coach_id", value: coachID)
            .eq("status", value: "pending")
            .order("created_at", ascending: false)
            .execute()

        return response.value
    }

    func fetchScorecardStats(scorecardID: Int) async throws -> [StatDetail] {
        let response: PostgrestResponse<[StatDetail]> = try await client
            .from("scorecard_stats")
            .select("*")
            .eq("scorecard_id", value: scorecardID)
            .execute()

        return response.value
    }
    
    
}
