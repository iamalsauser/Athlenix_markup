//
//  SignUpView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var message = ""
    @State private var isLoading = false
    @State private var selectedRole: String = "player"

    @Binding var userID: String?
    
    

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
            
            Picker("Select Role", selection: $selectedRole) {
                Text("Coach").tag("coach")
                Text("Player").tag("player")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            TextField("Display Name", text: $displayName)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            Button(action: {
                Task {
                    await signUp()
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Create Account")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    // MARK: - Sign Up Task

    func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            message = "All fields are required."
            return
        }

        isLoading = true
        message = ""

        do {
            let response = try await SupabaseService.shared.client.auth.signUp(
                email: email,
                password: password
            )

            let user = response.user  // ✅ no optional — remove `if let`

            // Save the profile after successful signup
            try await SupabaseService.shared.createProfile(
                userID: user.id,
                displayName: displayName,
                role: selectedRole
            )



            userID = user.id.uuidString
            message = "Sign-up successful! Please verify your email before logging in."
        } catch {
            message = "Sign-up failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
