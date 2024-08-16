//
//  SpotifyAuthManager.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/08/12.
//

import Foundation

// 文字列エンコード用の拡張機能（URL内で使用可能な文字に変換）
extension String {
    func percentEscaped() -> String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}
// Spotify APIの認証とAPI呼び出しを管理するクラス
class SpotifyAuthManager {
    static let shared = SpotifyAuthManager()
    let clientID = "cbec81689a284bc097930f139199ac2e"
    let clientSecret = "8d8203a29c8c41588d05fcc356340b7d"
    let redirectURI = "spotify-ios-quick-start://spotify-login-callback"
    var accessToken: String?

    // 認証URLを生成する関数
    func generateAuthURL() -> URL {
        let scopes = "user-read-private user-read-email".percentEscaped()
        let authURL = "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=code&redirect_uri=\(redirectURI.percentEscaped())&scope=\(scopes)"
        return URL(string: authURL)!
    }
    // アクセストークンをリクエストする関数
    func requestAccessToken(with code: String, completion: @escaping (String?) -> Void) {
        // トークンリクエストURL
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        // リクエストを作成
        var request = URLRequest(url: url)
        // メソッドはPOST
        request.httpMethod = "POST"
        // ボディパラメータを設定
        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        let bodyString = bodyParams.map { "\($0.key.percentEscaped())=\($0.value.percentEscaped())" }.joined(separator: "&")
        // ボディデータをエンコード
        request.httpBody = bodyString.data(using: .utf8)
        // ヘッダーを追加
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // リクエストを送信
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // エラーがあればnil
                completion(nil)
                return
            }
            // ステータスコードをチェック
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Failed to retrieve access token: HTTP \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            // JSONをパースしてアクセストークンを取得
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            self.accessToken = json?["access_token"] as? String
            completion(self.accessToken)
            // データタスクを開始
        }.resume()
    }

    // APIリクエストを送信して、トラック情報を取得する
    func fetchTrackInfo(trackID: String, completion: @escaping (TrackInfo?) -> Void) {
        guard let accessToken = self.accessToken else {
            // アクセストークンがない場合のエラーメッセージ
            print("Access token is missing")
            completion(nil)
            return
        }
        // トラック情報のURL
        let url = URL(string: "https://api.spotify.com/v1/tracks/\(trackID)")!
        // URLリクエスト作成
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch track info")
                completion(nil)
                return
            }
            // ステータスコードチェック
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Failed to retrieve track info: HTTP \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            // データをデコードしてTrackInfo構造体に変換
            let trackInfo = try? JSONDecoder().decode(TrackInfo.self, from: data)
            // デコード情報をコールバック
            completion(trackInfo)
            // データタスク開始
        }.resume()
    }
}
