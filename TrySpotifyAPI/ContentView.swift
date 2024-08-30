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
        spotifyManager.fetchPreviewURL(for: trackId) { previewUrl in
            // ローディングはfalse
            isLoading = false
            // urlをアンラップ　nilでないとき
            if let url = previewUrl {
                // urlをAVPlayerにセット
                player = AVPlayer(url: URL(string: url)!)
                // プレビュー再生
                player?.play()
                // nilのとき
            } else {
                // 失敗のプリント
                print("previewUrlの取得に失敗")
            } // if let url = previewUrl
        } // spotifyManager.fetchPreviewURL(for: trackId)
    } // func playPreview()
} // ContentView


#Preview {
    ContentView()
}
