//
//  SpotifyController+SPTAppRemoteDelegate.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/07/21.
//

import SwiftUI
import SpotifyiOS
import Combine

extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("Successfully subscribed to player state")
            } // if let
        }) // self.appRemote.playerAPI?.subscribe
    } // func appRemoteDidEstablishConnection
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        // Handle the connection failure
        print("通信がうまくいきません")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        // Handle the connection loss
        print("通信がうまくいきません")
    }
} // extension
