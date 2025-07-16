//
//  GamesView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 16/07/25.
//

import Foundation
import SwiftUI

struct GamesView: View {
    @StateObject var viewModel: GamesViewModel
    @State private var opponent = ""
    @State private var gameDate = Date()

    var body: some View {
        VStack {
            List(viewModel.games) { game in
                NavigationLink(
                    destination: StatsView(viewModel: StatsViewModel(gameID: game.id, teamID: viewModel.teamID))
                ) {
                    VStack(alignment: .leading) {
                        Text("🏀 \(game.opponent)")
                            .font(.headline)
                        Text("📅 \(formattedDate(game.game_date))")
                            .font(.subheadline)
                    }
                }
            }

            VStack(spacing: 10) {
                TextField("Opponent", text: $opponent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                DatePicker("Game Date", selection: $gameDate, displayedComponents: .date)
                    .datePickerStyle(.compact)

                Button("Add Game") {
                    Task {
                        // Creating ISO 8601 date string from the DatePicker
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withFullDate]
                        let dateString = formatter.string(from: gameDate)

                        await viewModel.addGame(opponent: opponent, date: dateString)
                        opponent = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(opponent.isEmpty)
            }
            .padding()

            if let error = viewModel.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Games")
    }

    private func formattedDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return isoDate
    }
}
