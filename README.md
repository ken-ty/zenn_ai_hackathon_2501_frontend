# AI Art Quiz Frontend

アート作品の解釈を巡る、AIとの知的な対決を楽しむクイズアプリケーション

## 概要

このアプリケーションは、アート作品に対する「投稿者の本来の解釈」と「AIが生成した説得力のある代替解釈」を比較するクイズゲームです。
プレイヤーは作品を見ながら、どちらが本物の投稿者による解釈なのかを見分けることに挑戦します。

## 特徴

- 🎨 オリジナルのアート作品表示
- 💭 投稿者による本物の解釈と、AIによる代替解釈の提示
- 🎮 直感的なゲームプレイ体験
- 📊 クイズの成績管理
- 🌟 美しいアニメーションとUI

## 技術スタック

- Flutter
- Dart
- REST API

## セットアップ

### 必要条件

- Flutter 3.x
- Dart 3.x
- Android Studio または VS Code

### インストール

1. 依存関係のインストール:

clone してください。

2. 依存関係のインストール:
```bash
flutter pub get
```

3. 環境変数の設定:
`.env.example`をコピーして`.env`を作成し、必要な値を設定:
```
API_ENDPOINT=your_api_endpoint_here
```

4. アプリケーションの起動:
```bash
flutter run
```

## アプリケーション構造

```
lib/
├── models/        # データモデル
├── pages/         # UI画面
├── services/      # APIサービス
├── utils/         # ユーティリティ関数
└── widgets/       # 再利用可能なウィジェット
```

## 主な機能

- **クイズプレイ**: アート作品を見ながら、本物の投稿者の解釈とAIの解釈を見分けるゲームプレイ
- **クイズのアップロード**: クイズをアップロードする

## 開発ガイドライン

- コードフォーマット:
```bash
flutter format .
```

- 静的解析:
```bash
flutter analyze
```

- テストの実行:
```bash
flutter test
```

## ライセンス

MIT License

## 貢献について

1. このリポジトリをフォーク
2. 新しい機能用のブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチをプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成
