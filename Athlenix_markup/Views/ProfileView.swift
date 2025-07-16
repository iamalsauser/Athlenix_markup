//
//  ProfileView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import SwiftUI

struct ProfileView: View {
    let userID: String
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Example: Display user name (call SupabaseService.fetchProfile if needed)
            Text("Profile")
                .font(.title.bold())

            Button("Log Out") {
                Task {
                    try? await SupabaseService.shared.logoutUser()
                    onLogout()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationTitle("Profile")
    }
}
