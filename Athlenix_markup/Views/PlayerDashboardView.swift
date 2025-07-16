import SwiftUI
import Foundation

struct PlayerDashboardView: View {
    let userID: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome Player 👋")
                    .font(.largeTitle)
                    .padding(.top)

                
                NavigationLink("📊 My Stats", destination: MyStatsView(userID: userID))
                NavigationLink("📅 My Games", destination: MyGamesView(userID: userID))

                Spacer()
            }
            .padding()
            .navigationTitle("Player Dashboard")
        }
    }
}
