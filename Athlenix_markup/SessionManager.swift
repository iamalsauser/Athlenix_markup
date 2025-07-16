//import Foundation
//import Supabase
//
//@MainActor
//class SessionManager: ObservableObject {
//    @Published var userID: String?
//    @Published var role: UserRole = .unknown
//    @Published var message: String = ""
//
//    func restoreSessionIfNeeded() async {
//        if let user = SupabaseService.shared.client.auth.currentUser {
//            userID = user.id.uuidString
//            await detectRole()
//        }
//    }
//
//    func detectRole() async {
//        guard let id = userID else {
//            role = .unknown
//            return
//        }
//        do {
//            let userRole = try await SupabaseService.shared.getUserRole(userID: id)
//            if let roleStr = userRole {
//                switch roleStr {
//                case "coach": role = .coach
//                case "player": role = .player
//                default: role = .unknown
//                }
//            } else {
//                role = .unknown
//            }
//        } catch {
//            print("detectRole error: \(error)")
//            role = .unknown
//        }
//    }
//
//    func login(email: String, password: String) async {
//        do {
//            let result = try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
//            let user = result.user
//            userID = user.id.uuidString
//            message = "Login successful"
//            await detectRole()
//        } catch {
//            message = "Login failed: \(error.localizedDescription)"
//        }
//    }
//
//    func logout() async {
//        try? await SupabaseService.shared.client.auth.signOut()
//        userID = nil
//        role = .unknown
//        message = ""
//    }
//}
