//
//  ContentView.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/08/12.
//

import SwiftUI
import AVFoundation

// タイマーの状態を管理するextension
extension SpotifyManager {
    // 状態を管理する列挙体
    enum State {
        // 再生中
        case playing
        // 停止
        case stopped
        // 一時停止
        case paused
    }
}

struct ContentView: View {
    // SpotifyManagerインスタンス
    @StateObject private var spotifyManager = SpotifyManager()
    // AVPlayerインスタンス
    @State private var player: AVPlayer?
    // ロード状態を管理する変数
    @State private var isLoading = false
    // サンプルは銀河鉄道999
    // https://open.spotify.com/intl-ja/track/2Oded9hR3DKNdkn9LUOkjb?si=286e8c239abe4c14
    // https://open.spotify.com/intl-ja/track/6MDfGuhAdrxkAMz9t0MM9M?si=f7e42876ac164688
    // https://open.spotify.com/intl-ja/track/3qvcbChw0dwMqk6BJkzIsR?si=a998fb409ab64bbd
    // 任意のトラックID
    let trackId = "2Oded9hR3DKNdkn9LUOkjb"
    // 通知の名前
    let notificationName = Notification.Name("notificationName")
    // 初期値を1分とする
    @State private var selectedTime: Int = 1
    // ユーザーが選択する時間のタイマー
    @State private var selectedTimer: Timer?
    // ユーザーが選択する時間のタイマーの終了時刻
    @State private var endTime: Date?
    // 音再生のタイマー
    @State private var soundTimer: Timer?
    //
    @State private var elapsedTime: Double = 0
    // fadeOutを管理
    @State private var isFadeOut = false
    // タイマーの状態　初期は.stopped
    @State private var state: SpotifyManager.State = .stopped
    var body: some View {
        VStack {
            // isLoadingがtrueなら
            if isLoading {
                // ローディング中
                ProgressView("Loading...")
                // falseなら
            } else {
                Picker("再生時間を選択", selection: $selectedTime) {
                    Text("1分").tag(1)
                    Text("3分").tag(3)
                    Text("5分").tag(5)
                    Text("10分").tag(10)
                    Text("20分").tag(20)
                    Text("30分").tag(30)
                    Text("40分").tag(40)
                    Text("50分").tag(50)
                    Text("60分").tag(60)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(height: 150)
                Text("\(Int(elapsedTime))秒")
                // 再生とタイマー開始ボタン表示
                Button(action: {
                    // 再生とタイマー開始
                    startPlayAndTimer()
                }) {
                    Text("プレビューを再生")
                } // Button
                // タイマーと再生停止ボタン表示
                Button(action: {
                    // 停止
                    updateState(newState: .paused)
                }) {
                    Text("停止")
                } // Button
                // 再開ボタン表示
                Button(action: {
                    // 再開
                    updateState(newState: .playing)
                }) {
                    Text("再開")
                } // Button
            } // if
        } // VStack
        .onAppear {
            stopTimer()
            elapsedTime = Double(selectedTime * 60)
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
        .onChange(of: selectedTime) {
            elapsedTime = Double(selectedTime * 60)
        }
        // 再生完了（音量0）の通知を受け取る
        .onReceive(NotificationCenter.default.publisher(for: notificationName)) { _ in
            print("音量が0になりました。再度再生をします")
            // endTimeが存在し、endTimeが過去だったら
            if let endTime = endTime, Date() >= endTime {
            } else {
                // タイマー終了5秒前の間にplayPreviewを実行しないようにする処理
                // isFadeOutがtrueなら
                if isFadeOut == true {
                    return
                    // それ以外なら
                } else {
                    // 音量が0になったら再生
                    playPreview()
                }
            } // if let endTime...
        } // .onReceive
    } // body
    
    func startPlayAndTimer() {
        // 終了時刻を計算
        endTime = Date(timeInterval: TimeInterval(selectedTime * 60), since: Date())
        // 再生を開始
        playPreview()
        // タイマーを開始
        startTimer()
        print("タイマーは\(endTime!)で終わり")
    }
    
    func startTimer() {
        // 多重でタイマーを開始しないようにする
        stopTimer()
        // 状態の更新(playing状態にする)
        updateState(newState: .playing)
        // 0.1秒ずつ刻む
        selectedTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // 現在日時から終了時刻まで0.1ずつ刻む
            elapsedTime = Date().timeIntervalSince(endTime!)
            print(elapsedTime)
            // endTimeが存在し、endTimeが過去だったら
            if let endTime = endTime, Date() >= endTime  {
                print("endTimeは過去です")
                // タイマーが終了したら再生を停止
                stopTimer()
                // フェードアウト
                if let player = player {
                    fadeOut(player: player, duration: 5.0)
                } else {
                    print("プレイヤーがnilです")
                }
            }
        }
            
    }
    
    func stopTimer() {
        selectedTimer?.invalidate()
        selectedTimer = nil
    }
    
    // 状態更新
    func updateState(newState: SpotifyManager.State) {
        if state == .playing && newState == .paused {
            player?.pause()
            stopTimer()
        } else if state == .paused && newState == .playing {
            player?.play()
            startTimer()
        }
        state = newState
    }
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
                        // endTimeから5秒前は必ずフェードアウト
                        if let endTime = endTime, Date() >= endTime - 5 {
                            fadeOut(player: player!, duration: 5.0)
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
                                // 5秒かけてフェードアウト
                                fadeOut(player: player!, duration: 5.0)
                            } // DispatchQuere
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
    // 自然に聞こえるフェードイン
    func fadeIn(player: AVPlayer, duration: TimeInterval) {
        // もしisFadeOutがtrueになったら
        if isFadeOut {
            // フェードインしない
            return
        }
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
    // 自然に聞こえるフェードアウト
    func fadeOut(player: AVPlayer, duration: TimeInterval) {
        // フェードアウトしているとき
        if isFadeOut == true {
            // 何も処理しない
            return
        } // if isFadeOut...
        isFadeOut = true
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
                isFadeOut = false
                // 音量が0になったら通知を送信
                NotificationCenter.default.post(name: notificationName, object: nil)
            } // if currentStep
        } // Timer
    } // func fadeOut
} // ContentView

#Preview {
    ContentView()
}
