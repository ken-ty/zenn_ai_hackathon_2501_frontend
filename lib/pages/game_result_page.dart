import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/pages/game_list_page.dart';

class GameResultPage extends StatelessWidget {
  const GameResultPage(
      {super.key, required this.trueAnswers, required this.totalQuestions});

  final int trueAnswers;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム結果'),
        backgroundColor: Colors.blueGrey[700],
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('お疲れ様でした！',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textScaler: const TextScaler.linear(1.5)),
              SizedBox(height: 32),
              Text('正答数: $trueAnswers / $totalQuestions',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textScaler: const TextScaler.linear(1.5)),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => GameListPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: const Text('ゲーム一覧に戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
