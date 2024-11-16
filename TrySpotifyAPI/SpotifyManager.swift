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
    // クライアントID
    let clientId = "cbec81689a284bc097930f139199ac2e"
    //　クライアントシークレット
    let clientSecret = "8d8203a29c8c41588d05fcc356340b7d"
    // アクセストークンの有効期限
    var expirationDate: Date? {
        // UserDefaultsから値を取り出しDate型へ
        get {
            return UserDefaults.standard.object(forKey: "access_token_expiration_date") as? Date
        }
        // 新しい値をUserDefaultsに保存
        set {
            UserDefaults.standard.set(newValue, forKey: "access_token_expiration_date")
        }
    }
    // 更新が必要な時間
    var updateDate: Date? {
        // UserDefaultsから値を取り出しDate型へ
        get {
            return UserDefaults.standard.object(forKey: "access_token_update_date") as? Date
        }
        // 新しい値をUserDefaultsに保存
        set {
            UserDefaults.standard.set(newValue, forKey: "access_token_update_date")
        }
    }
    // 初期化時にUserDefaultsからアクセストークンや有効期限を復元
    init() {
        self.accessToken = UserDefaults.standard.string(forKey: "access_token")
        self.expirationDate = UserDefaults.standard.object(forKey: "access_token_expiration_date") as? Date
        self.updateDate = UserDefaults.standard.object(forKey: "access_token_update_date") as? Date
        // アクセストークン、updateDateがnilでないとき
        if let accessToken = accessToken, let updateDate = updateDate {
            print("保存されたアクセストークンはこちら→ \(accessToken)")
            print("更新日時はこちら→\(updateDate)")
        } else {
            // nilのとき
            print("アクセストークンがありません")
        }
    }
    // アクセストークンを取得するための非同期処理
    func fetchAccessToken() async throws -> Bool {
        // 現在の日時
        let now = Date()
        // アクセストークンの有効期限がまだ切れていないならば
        if let expirationDate = expirationDate, let updateDate = updateDate, let accessToken = accessToken,
           Date() < expirationDate {
            print("現在\(Date())で、有効期限は\(updateDate)です。\n保存されたアクセストークンが有効です")
            print("保存されたアクセストークンは\n\(accessToken)")
            // trueを返し処理を終了
            return true
        }
        print("アクセストークンを再度取得します")
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
           // アクセストークンをString型に変換し、tokenに代入
           let token = jsonResponse["access_token"] as? String,
           // 有効時間をInt型に変換し、tokenに代入
           let expiresIn = jsonResponse["expires_in"] as? Int{
            await MainActor.run {
                // トークンをアクセストークンに代入
                self.accessToken = token
                // UserDefaultsに保存
                UserDefaults.standard.set(token, forKey: "access_token")
                // アクセストークンの有効期限を現在から1時間後（3600秒後）に設定
                self.expirationDate = Date(timeInterval: TimeInterval(expiresIn), since: now)
                // 更新は有効期限の5分前(300秒前)
                self.updateDate = Date(timeInterval: -60 * 5, since: self.expirationDate!)
                print("⭐️アクセストークンはこちら⭐️\n\(accessToken!)")
                print("⭐️トークンタイプはこちら⭐️\n\(jsonResponse["token_type"]!)")
                print("⭐️有効期限はこちら⭐️\n\(self.updateDate!)秒")
            }
            return true
        } else {
            print("アクセストークン取得失敗")
            return false
        } // if let
    } // func fetchAccessToken
    func fetchPreviewURL(for trackId: String) async throws -> String? {
        // アクセストークンがまだないか、期限切れならば取得
        if accessToken == nil || Date() >= (expirationDate ?? Date()) {
            let _ = try await fetchAccessToken()
        }
        // accessTokenをアンラップ
        guard let accessToken = accessToken else {
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
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
