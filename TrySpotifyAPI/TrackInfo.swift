//
//  TrackInfo.swift
//  TrySpotifyAPI
//
//  Created by apple on 2024/08/12.
//

import Foundation

// トラックのタイトル（名前）と、プレビューURLを管理する構造体
struct TrackInfo: Codable {
    let name: String
    let preview_url: String?
}
