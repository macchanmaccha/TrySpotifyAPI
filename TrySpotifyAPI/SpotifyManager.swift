//
//  SpotifyManager.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/08/12.
//

import Foundation

class SpotifyManager: ObservableObject {
    // アクセストークン
    @Published var accessToken: String?
    // リフレッシュトークン
    @Published var refreshToken: String?
    // クライアントID
    let clientId = "cbec81689a284bc097930f139199ac2e"
    //　クライアントシークレット
    let clientSecret = "8d8203a29c8c41588d05fcc356340b7d"
    
    // アクセストークンを取得するための非同期処理
    func fetchAccessToken() async throws -> Bool {
        // トークンURL　文字列からURLオブジェクトを生成、強制アンラップ
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        // URLリクエストを作成　URL、HTTPメソッド、ヘッダーなど含む
        var request = URLRequest(url: tokenURL)
        // IDとシークレットのデータ送信のためPOSTメソッドをhttpMethodに設定
        request.httpMethod = "POST"
        // リクエストの本文に必要なパラメータを設定
        // client_credentials方式を指定
        let bodyParameters = "grant_type=client_credentials"
        // UTF8形式のデータに変換して、リクエストボディに設定
        request.httpBody = bodyParameters.data(using: .utf8)
        // クライアントIDとクライアントシークレットをBase64にエンコードし、Authoraizationヘッダーに設定
        let authValue = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        // サーバーに対してリクエストを送信するクライアントの認証情報を伝える
        // Basic認証
        request.setValue("Basic \(authValue)", forHTTPHeaderField: "Authorization")
        // リクエストのデータがapplication...の形式（キーと値のペア）
        // リクエストのContent-Typeヘッダーを設定
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // データダウンロード等するURLSessionを使って非同期でURLリクエストを送信
        // taskでURLリクエストを渡しレスポンスを受け取る　データ、レスポンス、エラー
        let (data, _) = try await URLSession.shared.data(for: request)
        // レスポンスのJSONをパースし、アクセストークンを取得
        // JSONデータをSwiftのデータ型に変換
        // エラーが発生したらnilを返す
        // パースはdataを指定、オプションの指定なし、キーはString、値はAny
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data,  options: []) as? [String: Any],
           // String型に変換し、tokenに代入
           let token = jsonResponse["access_token"] as? String {
            await MainActor.run {
                // トークンをアクセストークンに代入
                self.accessToken = token
            }
            return true
        } // if let
        return false
    } // func fetchAccessToken
    func fetchPreviewURL(for trackId: String) async throws -> String? {
        guard let token = accessToken else {
            print("アクセストークンがありません")
            // アクセストークンがnilのとき、nilを渡す
            return nil
        } // guard let
        // 楽曲のID
        guard let url = URL(string: "https://api.spotify.com/v1/tracks/\(trackId)") else {
            return nil
        }
        // URLリクエスト
        var request = URLRequest(url: url)
        // APIリクエストをする
        // BearerトークンをAuthorizationの設定
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           // プレビューURLをString型へ
           let previewUrl = jsonResponse["preview_url"] as? String {
            return previewUrl
        } else {
            // nilを通知
            return nil
        } // if let
    }
} // class
