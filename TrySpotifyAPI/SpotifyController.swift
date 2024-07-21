//
//  SpotifyController.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/07/20.
//

import SwiftUI
import SpotifyiOS
import Combine

@MainActor
final class SpotifyController: NSObject, ObservableObject {
    let spotifyClientID = "cbec81689a284bc097930f139199ac2e"
    let spotifyRedirectURL = URL(string:"spotify-ios-quick-start://spotify-login-callback")!
    
    var accessToken: String? = nil
    
    @Published var currentTrackURI: String?
    @Published var currentTrackName: String?
    @Published var currentTrackArtist: String?
    @Published var currentTrackDuration: Int?
    @Published var currentTrackImage: UIImage?
    
    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    ) // lazy var configuration
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }() // lazy var appRemote: SPTAppRemote
    
    override init() {
        super.init()
        /*connectCancellable = */NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.connect()
            } // .stink
        
        /*disconnectCancellable = */NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.disconnect()
            } // .stink
    } // override init()
    
    func connect() {
        if let _ = self.appRemote.connectionParameters.accessToken {
            appRemote.connect()
        } // if let
    } // func connect()
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        } // if appRemote.isConnected
    } // func disconnect()
    
    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Handle the error
        } // if let accessToken ...
    } // func setAccessToken
    
    func authorize() {
        self.appRemote.authorizeAndPlayURI("")
    } // func authorize()
    
    func fetchImage() {
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let error = error {
                print("Error getting player state: \(error)")
            } else if let playerState = result as? SPTAppRemotePlayerState {
                self.appRemote.imageAPI?.fetchImage(forItem: playerState.track, with: CGSize(width: 300, height: 300), callback: { (image, error) in
                    if let error = error {
                        print("Error fetching track image: \(error.localizedDescription)")
                    } else if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.currentTrackImage = image
                        } // DispatchQueue.main.async
                    } // if let image
                }) // self.appRemote.imageAPI?.fetchImage
            } // if let error
        } // appRemote.playerAPI?.getPlayerState
    } // func fetchImate
    
} // class SpotifyController

