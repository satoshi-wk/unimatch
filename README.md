# unimatch

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# メモ 
# 導入
https://www.flutter-study.dev/getting-started/run-app
- `flutter create myapp`
# Flutter アプリに Firebase を追加する
ワークスペースの準備
- FlutterFire CLI を使用して簡単に始めることができます。
- 続行する前に、必ず以下の操作を行ってください。
    - Firebase CLI をインストールしてログインする（firebase login を実行する）
    - Flutter SDK をインストールする
    - Flutter プロジェクトを作成する（flutter create を実行する）
    - `npm install -g firebase-tools`
    - `firebase login`
    - 任意のディレクトリから次のコマンドを実行します。
    - `dart pub global activate flutterfire_cli`
    - `export PATH="$PATH":"$HOME/.pub-cache/bin"`
    - 続いて、Flutter プロジェクト ディレクトリのルートで次のコマンドを実行します。
    - `flutterfire configure --project=unimatch-63d64`
    - これで、プラットフォームごとのアプリが Firebase に自動的に登録され、lib/firebase_options.dart 構成ファイルが Flutter プロジェクトに追加されます。
    - Firebase を初期化するには、新しい firebase_options.dart ファイルの構成を使用して、firebase_core パッケージから Firebase.InitializeApp を呼び出します。
```
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ...

await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
```
    - https://firebase.google.com/docs/flutter/setup?hl=ja&authuser=6&platform=ios
    - `flutter pub add firebase_core`
    - `flutterfire configure`
    - `flutter pub add firebase_auth`
    - `flutter pub add flutter_riverpod`

## 起動
- `flutter run -d Chrome`