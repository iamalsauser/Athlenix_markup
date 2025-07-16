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
        VStack(spacing: 16) {
            if let profile = profile {
                Text(profile.display_name ?? "Unnamed Player")
                    .font(.title.bold())
                // Add more info in future (e.g. avatar, email...)
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
        .padding()
        .navigationTitle("Profile")
        .task {
            await loadProfile()
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
