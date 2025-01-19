import 'package:zenn_ai_hackathon_2501_frontend/models/image_origin.dart';

enum GameResult {
  win,
  lose,
}

class Judgment {
  static GameResult judgeGameResult(ImageOrigin origin) {
    if (origin == ImageOrigin.madebyhuman) {
      return GameResult.win;
    } else {
      return GameResult.lose;
    }
  }
}
