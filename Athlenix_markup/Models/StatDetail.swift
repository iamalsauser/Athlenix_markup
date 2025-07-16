//
//  StatDetail.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import Foundation

//struct StatDetail: Identifiable, Codable {
//    let id: Int
//    let points: Int
//    let assists: Int
//    let rebounds: Int
//    let opponentName: String
//}
struct StatDetail: Identifiable, Codable {
    let id: Int  // or another unique field
    let player_id: Int
    let points: Int
    let assists: Int
    let rebounds: Int
    let opponentName: String
}
