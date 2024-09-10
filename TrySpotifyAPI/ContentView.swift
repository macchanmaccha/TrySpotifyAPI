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
            // fetchAccessTokenを呼び出す
            spotifyManager.fetchAccessToken { succses in
                // アクセストークンの取得がsuccessの場合
                if succses {
                    // 特になし
                    // アクセストークンの取得がfalseの場合
                } else {
                    // アクセストークン取得失敗とプリント
                    print("アクセストークン取得失敗")
                }//  if succses
            } // spotifyManager.fetchAccessToken { succses in
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
                let urlString = try await spotifyManager.fetchPreviewURL(for: trackId)
                // urlをAVPlayerにセット
                player = AVPlayer(url: URL(string: urlString!)!)
                // ローディングはfalse
                isLoading = false
                // プレビュー再生
                player?.play()
            } catch {
                // ローディングはfalse
                isLoading = false
                // 失敗のプリント
                print("previewUrlの取得に失敗")
            }
        } // Task
    } // func playPreview()
} // ContentView


#Preview {
    ContentView()
}
