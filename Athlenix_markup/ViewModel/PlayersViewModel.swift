import Foundation

class PlayersViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var profiles: [Profile] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    let teamID: Int
    let coachUserID: String  // <-- Make sure to set the type

    // Initializer now requires coachUserID to be passed in
    init(teamID: Int, coachUserID: String) {
        self.teamID = teamID
        self.coachUserID = coachUserID

        Task {
            await fetch()
            await fetchProfiles()
        }
    }

    @MainActor
    func fetch() async {
        isLoading = true
        errorMessage = nil
        do {
            players = try await SupabaseService.shared.fetchPlayers(teamID: teamID)
        } catch {
            errorMessage = "Failed to load players: \(error.localizedDescription)"
        }
        isLoading = false
    }

    @MainActor
    func fetchProfiles() async {
        do {
            profiles = try await SupabaseService.shared.fetchAllProfiles()
        } catch {
            errorMessage = "Failed to load users: \(error.localizedDescription)"
        }
    }

    @MainActor
    func addPlayer(from profile: Profile, number: Int) async {
        errorMessage = nil
        guard let name = profile.display_name else {
            errorMessage = "User is missing a display name."
            return
        }

        do {
            try await SupabaseService.shared.addPlayer(
                name: name,
                number: number,
                teamID: teamID,
                userID: profile.id
            )
            await fetch()
        } catch {
            errorMessage = "Failed to add player: \(error.localizedDescription)"
        }
    }
}
