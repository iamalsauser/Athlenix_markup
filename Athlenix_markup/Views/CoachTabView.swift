//
//  CoachTabView.swift
//  Athlenix_markup
//
//  Created by Parth Sinh on 17/07/25.
//


import SwiftUI

struct CoachTabView: View {
    let userID: String
    let onLogout: () -> Void

    var body: some View {
        TabView {
            TeamsView(viewModel: TeamsViewModel(userID: userID), onLogout: onLogout)
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }
            GamesOverviewView(userID: userID)
                .tabItem {
                    Label("Games", systemImage: "calendar")
                }
            ProfileView(userID: userID, onLogout: onLogout)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
