//
//  PlayerTeamsViewModel.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import Foundation
import Supabase

@MainActor
class PlayerTeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    func fetchTeams(for userID: String) async {
        isLoading = true
        do {
            teams = try await SupabaseService.shared.fetchTeamsForPlayer(userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
