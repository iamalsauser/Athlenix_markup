import Foundation

struct Player: Codable, Identifiable {
    let id: Int
    let team_id: Int
    let name: String
    let number: Int?
    let user_id: String? // link to registered user
}
