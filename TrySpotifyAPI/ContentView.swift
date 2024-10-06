//
//  ContentView.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/08/12.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    // SpotifyManagerインスタンス
    @StateObject private var spotifyManager = SpotifyManager()
    // AVPlayerインスタンス
    @State private var player: AVPlayer?
    // ロード状態を管理する変数
    @State private var isLoading = false
    // サンプルは銀河鉄道999 https://open.spotify.com/intl-ja/track/2Oded9hR3DKNdkn9LUOkjb?si=286e8c239abe4c14
    // 任意のトラックID
    let trackId = "2Oded9hR3DKNdkn9LUOkjb"
    var body: some View {
        VStack {
            // isLoadingがtrueなら
            if isLoading {
                // ローディング中
                ProgressView("Loading...")
                // falseなら
            } else {
                // ボタン表示
                Button(action: {
                    // プレビュー再生
                    playPreview()
                }) {
                    Text("プレビューを再生")
                } // Button
            } // if
        } // VStack
        .onAppear {
            Task {
                do {
                    // アクセストークンが有効であれば
                    if try await spotifyManager.fetchAccessToken() {
                        print("アクセストークンは有効です")
                        if let urlString = try await spotifyManager.fetchPreviewURL(for: trackId) {
                            // urlをAVPlayerにセット
                            player = AVPlayer(url: URL(string: urlString)!)
                            // ローディングはfalse
                            isLoading = false
                        }
                    } else {
                        print("アクセストークンが無効です")
                    } // if try await spotifyManager.fetchAccessToken()
                } catch {
                    // ローディングはfalse
                    isLoading = false
                    // 失敗のプリント
                    print("previewUrlの取得に失敗")
                }
            } // Task
        } // .onAppear
    } // body
    // プレビュー再生
    func playPreview() {
        // ローディングはtrue
        isLoading = true
        // fetchPreviewURLを呼びだす
        // trackIDのpreviewUrlを取得
        Task {
            do {
                // アクセストークンが有効であれば
                if try await spotifyManager.fetchAccessToken() {
                    print("アクセストークンは有効です")
                    if let previewURL = try await spotifyManager.fetchPreviewURL(for: trackId) {
                        // urlをAVPlayerにセット
                        player = AVPlayer(url: URL(string: previewURL)!)
                        // プレビュー再生
                        player?.play()
                    }
                } else {
                    print("アクセストークンが無効です")
                }
            } catch {
                // 失敗のプリント
                print("previewUrlの取得に失敗")
            }
            isLoading = false
        } // Task
    } // func playPreview()
} // ContentView


#Preview {
    ContentView()
}
