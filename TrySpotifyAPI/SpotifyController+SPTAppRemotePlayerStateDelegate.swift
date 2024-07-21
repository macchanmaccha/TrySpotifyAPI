//
//  SpotifyController+SPTAppRemotePlayerStateDelegate.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/07/21.
//

import SwiftUI
import SpotifyiOS
import Combine

extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.currentTrackURI = playerState.track.uri
        self.currentTrackName = playerState.track.name
        self.currentTrackArtist = playerState.track.artist.name
        self.currentTrackDuration = Int(playerState.track.duration) / 1000 // playerState.track.duration is in milliseconds
        fetchImage()
    } // func playerStateDidChange
} // extension
