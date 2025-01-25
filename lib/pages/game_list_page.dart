import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/pages/game_page.dart';

// ElevatedButtonを作成する関数
ElevatedButton createGameButton({
  required BuildContext context, // contextを追加
  required String buttonText,
  required String gameTitle,
  required Color backgroundColor,
}) {
  return ElevatedButton(
    onPressed: () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => GamePage(title: gameTitle)),
        (Route<dynamic> route) => false,
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
      minimumSize: const Size(210, 0), // 幅を210に設定、高さは自動調整
    ),
    child: Text(buttonText),
  );
}

class GameListPage extends StatelessWidget {
  const GameListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                createGameButton(
                  context: context,
                  buttonText: 'イージーモード',
                  gameTitle: 'Easy Game Screen',
                  backgroundColor: Colors.blue[600]!,
                ),
                const SizedBox(height: 16),
                createGameButton(
                  context: context,
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
