import SwiftUI

struct ScorecardStatsView: View {
    let stats: [StatDetail]  // Plain array!

    var body: some View {
        NavigationStack {
            List(stats) { stat in
                VStack(alignment: .leading) {
                    Text("Player ID: \(stat.player_id)")
                        .bold()
                    HStack {
                        Text("Points: \(stat.points)")
                        Spacer()
                        Text("Assists: \(stat.assists)")
                        Spacer()
                        Text("Rebounds: \(stat.rebounds)")
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Scorecard Stats")
        }
    }
}
