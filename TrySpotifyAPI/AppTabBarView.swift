//
//  ContentView.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/07/15.
//

import SwiftUI

struct AppTabBarView: View {
    @StateObject private var spotifyController = SpotifyController()
    
    var body: some View {
        Button {
            if !spotifyController.appRemote.isConnected {
                spotifyController.authorize()
            } // if
        } label: {
            Text("Welcom to Spotify")
        } // Button
        .onOpenURL { url in
            spotifyController.setAccessToken(from: url)
        } // .onOpenURL
        .environmentObject(spotifyController)
    } // body
} // AppTabBarView

#Preview {
    AppTabBarView()
}

