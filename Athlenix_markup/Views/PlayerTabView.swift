//
//  PlayerTabView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import SwiftUI

struct PlayerTabView: View {
    let userID: String
    let onLogout: () -> Void

    var body: some View {
        TabView {
            MyTeamsView(userID: userID)
                .tabItem {
                    Label("Teams", systemImage: "person.3")
                }
            MyGamesView(userID: userID)
                .tabItem {
                    Label("Games", systemImage: "basketball")
                }
            ProfileView(userID: userID, onLogout: onLogout)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
