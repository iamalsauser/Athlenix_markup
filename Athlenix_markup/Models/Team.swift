import Foundation

struct Team: Codable, Identifiable {
    let id: Int
    let name: String
    let coach_user_id: String
}
