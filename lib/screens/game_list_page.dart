import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/screens/game_screen.dart';

// ElevatedButtonを作成する関数
SizedBox gameButtonBox({
  required String buttonText,
  required String gameTitle,
  required Color backgroundColor,
}) {
  return SizedBox(
    width: 210,
    child: ElevatedButton(
      onPressed: () {
        // 画面遷移の処理は共通なので関数内で記述
        // pushReplacementで戻るボタンを無効化
        // pushだと画面遷移履歴が残り、戻るボタンで戻れてしまう
        Navigator.pushReplacement(
          navigatorKey.currentContext!, //navigatorKeyを使用
          MaterialPageRoute(
            builder: (context) => GameScreen(title: gameTitle),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      ),
      child: Text(buttonText),
    ),
  );
}

//Navigatorのkeyを定義
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class GameListPage extends StatelessWidget {
  const GameListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // MaterialAppで囲む
      navigatorKey: navigatorKey, //navigatorKeyを設定
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ゲーム一覧'),
          backgroundColor: Colors.blueGrey[700],
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                gameButtonBox(
                  // 関数を使ってボタンを作成
                  buttonText: 'イージーモード',
                  gameTitle: 'Easy Game Screen',
                  backgroundColor: Colors.blue[600]!,
                ),
                const SizedBox(height: 16),
                gameButtonBox(
                  // 関数を使ってボタンを作成
                  buttonText: 'ハードモード',
                  gameTitle: 'Hard Game Screen',
                  backgroundColor: Colors.red[600]!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
