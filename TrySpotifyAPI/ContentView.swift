//
//  ContentView.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/08/12.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var spotifyAuthManager = SpotifyAuthManager()
    // トラック情報を保持する状態変数
    @State private var trackInfo: TrackInfo?
    // オーディオプレイヤーのインスタンスを保持する状態変数
    @State private var player: AVPlayer?
    var body: some View {
        VStack {
            // トラック状態が存在する場合
            if let trackInfo = trackInfo {
                // トラック名を表示
                Text("Track Name: \(trackInfo.name)")
                // プレビューURLが存在し、正しいURLに変換できる場合
                if let previewURL = trackInfo.preview_url, let url = URL(string: previewURL) {
                    // ボタン
                    Button("Play Preview") {
                        // プレイヤーにプレビューURLをセット
                        player = AVPlayer(url: url)
                        // プレイヤー再生
                        player?.play()
                    }
                } else {
                    // プレビューが再生できない時のメッセージ
                    Text("Preview not available")
                }
                // トラック情報が存在しない場合
            } else {
                // ボタン
                Button("Fetch Track Info") {
                    // トラック情報を取得
                    fetchTrackInfo()
                }
            }
        }
        .padding()
    }
    
    /// トラック情報をSpotify APIから取得する関数
    func fetchTrackInfo() {
        // リクエストするURLを設定（トラックIDを指定）
        guard let url = URL(string: "https://api.spotify.com/v1/tracks/2TpxZ7JUBn3uw46aR7qd6V") else {
            print("Invalid URL")
            return
        }
        // URLリクエストの作成
        var request = URLRequest(url: url)
        // HTTPメソッドをGETに設定
        request.httpMethod = "GET"
        // リクエストヘッダーにアクセストークンを追加
        request.setValue("Bearer \(String(describing: spotifyAuthManager.accessToken))", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // エラーチェック
            if let error = error {
                // エラーが発生した場合のログ出力
                print("Error: \(error.localizedDescription)")
                return
            }
            // 取得したデータをログ出力（デバッグ用）
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
            }
            // データタスクを開始
        }.resume()
    }
}


#Preview {
    ContentView()
}
