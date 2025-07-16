//
//  GameDetail.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
//import Foundation

struct GameDetail: Identifiable, Codable {
    let id: Int
    let team_id: Int
    let opponent: String
    let date: String    // or game_date, as per your schema/view
}
