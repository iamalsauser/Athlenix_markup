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
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                }

                Section(header: Text("Enter Stat Line")) {
                    TextField("Points", text: $points)
                        .keyboardType(.numberPad)
                        .accessibilityLabel("Points")
                    TextField("Assists", text: $assists)
                        .keyboardType(.numberPad)
                        .accessibilityLabel("Assists")
                    TextField("Rebounds", text: $rebounds)
                        .keyboardType(.numberPad)
                        .accessibilityLabel("Rebounds")
                }
            }
            .navigationTitle("Stat for \(player.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        Task {
                            await saveStat()
                            dismiss()
                        }
                    }) {
                        Label("Save", systemImage: "checkmark")
                    }
                    .disabled(!valid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Label("Cancel", systemImage: "xmark")
                    }
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
