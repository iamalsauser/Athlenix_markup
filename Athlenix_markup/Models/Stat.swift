import Foundation

struct Stat: Codable, Identifiable {
    let id: Int
    let player_id: Int
    let game_id: Int
    let points: Int
    let assists: Int
    let rebounds: Int
}
