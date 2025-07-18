//
//  profile.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import SwiftUI

//import Foundation

struct Profile: Codable, Identifiable, Hashable {
    let id: String
    let email: String?
    let display_name: String?
    let role: String?
}
