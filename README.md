# TrySpotifyAPI

Spotify Web API を使った再生まわりの検証用 SwiftUI アプリです。  
本アプリ [Breath Trip](https://github.com/CodeCandySchool/MeditationJourney_may) 向けに、楽曲プレビュー取得〜再生制御の実装を試したプロジェクトです。

## できること

- Spotify API でアクセストークンを取得（Client Credentials）
- トラック ID からプレビュー URL を取得
- `AVPlayer` によるプレビュー再生
- 再生時間の選択（1〜60分）
- フェードイン / フェードアウト
- 再生・停止・再開

## 技術スタック

- Swift / SwiftUI
- Spotify Web API
- URLSession（非同期通信）
- AVFoundation
- UserDefaults（トークンの一時保存）

## 関連プロジェクト

- [Breath Trip](https://github.com/CodeCandySchool/MeditationJourney_may)
- [TryAppleMusicAPI](https://github.com/CodeCandySchool/TryAppleMusicAPI_may)

## 補足

テスト・学習用の簡易アプリです。本番アプリへの組み込み前の API 検証を目的としています。
