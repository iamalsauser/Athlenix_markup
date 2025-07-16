import SwiftUI
import Supabase

enum UserRole: String, Codable, Equatable {
    case coach
    case player
    case unknown
}

@MainActor
class SessionManager: ObservableObject {
    @Published var userID: String?
    @Published var role: UserRole = .unknown
    @Published var message: String = ""

    func restoreSessionIfNeeded() async {
        if let user = SupabaseService.shared.client.auth.currentUser {
            userID = user.id.uuidString
            await detectRole()
        }
    }

    func detectRole() async {
        guard let id = userID else {
            role = .unknown
            return
        }
        do {
            let userRole = try await SupabaseService.shared.getUserRole(userID: id)
            if let roleStr = userRole {
                switch roleStr {
                case "coach": role = .coach
                case "player": role = .player
                default: role = .unknown
                }
            } else {
                role = .unknown
            }
        } catch {
            print("detectRole error: \(error.localizedDescription)")
            role = .unknown
        }
    }

    func login(email: String, password: String) async {
        do {
            let result = try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
            let user = result.user
            userID = user.id.uuidString
            message = "Login successful"
            await detectRole()
        } catch {
            message = "Login failed: \(error.localizedDescription)"
        }
    }

    func logout() async {
        try? await SupabaseService.shared.client.auth.signOut()
        userID = nil
        role = .unknown
        message = ""
    }
}

struct ContentView: View {
//    @StateObject private var session = SessionManager()
    @EnvironmentObject var session: SessionManager

    @State private var email = ""
    @State private var password = ""
    @State private var showingSignup = false

    var body: some View {
        Group {
            if let id = session.userID {
                switch session.role {
                case .coach:
                    CoachTabView(userID: id, onLogout: logout)
                case .player:
                    PlayerTabView(userID: id, onLogout: logout)
                case .unknown:
                    VStack(spacing: 20) {
                                ProgressView("Loading role...")
                                Button("Logout") {
                                    logout()
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                            .padding()
                        }
            } else {
                loginView
            }
        }
        .onAppear {
            Task {
                await session.restoreSessionIfNeeded()
            }
        }
    }

    var loginView: some View {
        VStack(spacing: 20) {
            Text("Athlinix Login")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke())

            SecureField("Password", text: $password)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke())

            Button {
                Task {
                    await session.login(email: email, password: password)
                }
            } label: {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Don't have an account? Sign Up") {
                showingSignup = true
            }

            if !session.message.isEmpty {
                Text(session.message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .padding()
        .sheet(isPresented: $showingSignup) {
            SignupView(userID: $session.userID)
        }
    }

    
    
    func logout() {
        Task {
            await session.logout()
            email = ""
            password = ""
        }
    }
}
