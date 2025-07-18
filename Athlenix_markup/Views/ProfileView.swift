import SwiftUI

struct ProfileView: View {
    let userID: String
    let onLogout: () -> Void

    @State private var profile: Profile?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView("Loading profile...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let profile = profile {
                    VStack(spacing: 12) {
                        Text(profile.display_name?.isEmpty == false ? profile.display_name! : "No name set")
                            .font(.title.bold())
                            .accessibilityAddTraits(.isHeader)
                        if let email = profile.email {
                            Text(email)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        if let role = profile.role {
                            Label(role.capitalized, systemImage: role == "coach" ? "person.crop.square.filled.and.at.rectangle" : "person.fill")
                                .font(.subheadline)
                                .foregroundColor(role == "coach" ? .blue : .green)
                        }
                    }
                    .padding(.bottom, 24)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(errorMessage)")
                }

                Button(action: {
                    Task {
                        try? await SupabaseService.shared.logoutUser()
                        onLogout()
                    }
                }) {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .accessibilityLabel("Log Out")

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProfile()
            }
        }
    }

    // MARK: - Fetch User Profile
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let userProfile = try await SupabaseService.shared.fetchProfile(userID: userID) {
                self.profile = userProfile
            } else {
                self.errorMessage = "Profile not found."
            }
        } catch {
            self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }
}
