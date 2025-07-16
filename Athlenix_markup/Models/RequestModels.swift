import Foundation

struct NewTeam: Codable {
    let name: String
    let coach_user_id: String
}

struct NewPlayer: Codable {
    let name: String
    let number: Int
    let team_id: Int
}

struct NewPlayerWithUser: Codable {
    let name: String
    let number: Int
    let team_id: Int
    let user_id: String
}

struct NewGame: Codable {
    let opponent: String
    let game_date: String
    let team_id: Int
}

struct NewStat: Codable {
    let player_id: Int
    let game_id: Int
    let points: Int
    let assists: Int
    let rebounds: Int
}

struct NewProfile: Codable {
    let id: String
    let display_name: String
}
