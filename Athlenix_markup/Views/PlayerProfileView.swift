//
//  PlayerProfileView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import SwiftUI

struct PlayerProfileView: View {
    let userID: String
    @State private var profile: Profile?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let profile = profile {
                    Text(profile.display_name ?? "Unnamed Player")
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)
                    // Add more info in future (e.g. avatar, email...)
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityLabel("Error: \(error)")
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
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

    func loadProfile() async {
        do {
            self.profile = try await SupabaseService.shared.fetchProfile(userID: userID)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
