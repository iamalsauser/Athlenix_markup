import Foundation

struct Game: Codable, Identifiable {
    let id: Int
    let team_id: Int
    let opponent: String
    let game_date: String // ISO 8601: use Date if you prefer decoding to Date
}
