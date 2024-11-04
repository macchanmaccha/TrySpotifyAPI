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
    // https://open.spotify.com/intl-ja/track/6MDfGuhAdrxkAMz9t0MM9M?si=f7e42876ac164688
    // https://open.spotify.com/intl-ja/track/3qvcbChw0dwMqk6BJkzIsR?si=a998fb409ab64bbd
    // 任意のトラックID
    let trackId = "2Oded9hR3DKNdkn9LUOkjb"
    let now = Date()
    // 通知の名前
    let notificationName = Notification.Name("notificationName")
    
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
                    
                    if let urlString = try await spotifyManager.fetchPreviewURL(for: trackId) {
                        // urlをAVPlayerにセット
                        player = AVPlayer(url: URL(string: urlString)!)
                        // ローディングはfalse
                        isLoading = false
                    }
                } catch {
                    // ローディングはfalse
                    isLoading = false
                    // 失敗のプリント
                    print("previewUrlの取得に失敗")
                }
            } // Task
        } // .onAppear
        // 再生完了（音量0）の通知を受け取る
        .onReceive(NotificationCenter.default.publisher(for: notificationName)) { _ in
            print("音量が0になりました。再度再生をします")
            // 音量が0になったら再生
            playPreview()
        } // .onReceive
    } // body
    // プレビュー再生
    func playPreview() {
        // ローディングはtrue
        isLoading = true
        // fetchPreviewURLを呼びだす
        // trackIDのpreviewUrlを取得
        Task {
            do {
                if try await spotifyManager.fetchAccessToken() {
                    if let previewURL = try await spotifyManager.fetchPreviewURL(for: trackId) {
                        // urlをAVPlayerにセット
                        player = AVPlayer(url: URL(string: previewURL)!)
                        player?.volume = 1.0
                        // プレビュー再生
                        player?.play()
                        // フェードイン
                        fadeIn(player: player!, duration: 5.0)
                        // フェードアウト
                        // 25秒後にフェードアウト
                        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
                            // 5秒かけてフェードアウト
                            fadeOut(player: player!, duration: 5.0)
                        }
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
    // 自然に聞こえるフェードインフェードアウト
    func fadeIn(player: AVPlayer, duration: TimeInterval) {
        let fadeDuration = duration
        // 100ミリ秒ごとに音量を変更
        let interval: TimeInterval = 0.1
        let totalSteps = Int(fadeDuration / interval)
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if currentStep < totalSteps {
                // 音量の変更を指数関数的に調整
                let normalizedTime = Double(currentStep) / Double(totalSteps)
                // 2乗することで、初期はゆっくり、後半は急激に上昇
                player.volume = Float(pow(normalizedTime, 2))
                currentStep += 1
            } else {
                // 最大音量に設定
                player.volume = 1.0
                timer.invalidate()
            }
        }
    }
    func fadeOut(player: AVPlayer, duration: TimeInterval) {
        let fadeDuration = duration
        let interval: TimeInterval = 0.1
        let totalSteps = Int(fadeDuration / interval)
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if currentStep < totalSteps {
                // 音量の変更を指数関数的に調整
                let normalizedTime = Double(currentStep) / Double(totalSteps)
                // フェードインとは逆に音量が徐々に減少
                player.volume = Float(pow(1.0 - normalizedTime, 2))
                currentStep += 1
            } else {
                // 音量をゼロに設定
                player.volume = 0.0
                player.pause()
                timer.invalidate()
                // 音量が0になったら通知を送信
                NotificationCenter.default.post(name: notificationName, object: nil)
            } // if currentStep
        } // Timer
    } // func fadeOut
} // ContentView


#Preview {
    ContentView()
}
