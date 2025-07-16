import Foundation

class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Add your userID loading logic
    let userID: String

    init(userID: String) {
        self.userID = userID
        Task { await loadTeams() }
    }

    @MainActor
    func loadTeams() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await SupabaseService.shared.fetchTeams(for: userID)
            teams = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func addTeam(name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await SupabaseService.shared.addTeam(name: name, coachUserID: userID)
            await loadTeams()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
