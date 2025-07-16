//
//  AddStatSheet.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import SwiftUI

struct AddStatSheet: View {
    let gameID: Int
    let player: Player
    var onStatAdded: () -> Void

    @State private var points = ""
    @State private var assists = ""
    @State private var rebounds = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Player")) {
                    Text(player.name)
                }

                Section(header: Text("Enter Stat Line")) {
                    TextField("Points", text: $points)
                        .keyboardType(.numberPad)
                    TextField("Assists", text: $assists)
                        .keyboardType(.numberPad)
                    TextField("Rebounds", text: $rebounds)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Stat for \(player.name)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveStat()
                            dismiss()
                        }
                    }.disabled(!valid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    var valid: Bool {
        Int(points) != nil && Int(assists) != nil && Int(rebounds) != nil
    }

    func saveStat() async {
        do {
            try await SupabaseService.shared.addStat(
                playerID: player.id,
                gameID: gameID,
                points: Int(points)!,
                assists: Int(assists)!,
                rebounds: Int(rebounds)!
            )
            onStatAdded()
        } catch {
            // Handle error UI as desired
        }
    }
}
