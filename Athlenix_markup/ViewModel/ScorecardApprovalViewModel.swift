//
//  ScorecardApprovalViewModel.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import Foundation

@MainActor
class ScorecardApprovalViewModel: ObservableObject {
    @Published var scorecards: [PendingScorecard] = []
    @Published var selectedScorecardStats: [StatDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let coachID: String

    init(coachID: String) {
        self.coachID = coachID
    }

    func fetchPendingScorecards() async {
        isLoading = true
        do {
            scorecards = try await SupabaseService.shared.fetchPendingScorecards(coachID: coachID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchStats(forScorecard scorecardID: Int) async {
        isLoading = true
        do {
            selectedScorecardStats = try await SupabaseService.shared.fetchScorecardStats(scorecardID: scorecardID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func approve(scorecardID: Int) async {
        isLoading = true
        do {
            try await SupabaseService.shared.approveScorecard(scorecardID: scorecardID)
            await fetchPendingScorecards() // refresh list
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func reject(scorecardID: Int) async {
        isLoading = true
        do {
            try await SupabaseService.shared.rejectScorecard(scorecardID: scorecardID)
            await fetchPendingScorecards() // refresh list
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
