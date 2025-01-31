import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/lottie_animation.dart';

Future<void> showPopup(BuildContext context, Answer answer) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Stack(children: [
        Positioned(
          child: AlertDialog(
            title: Text(
              answer.pictureTitle,
              textAlign: TextAlign.center,
            ),
            content: (answer.pictureOriginalPath.startsWith('http://') ||
                    answer.pictureOriginalPath.startsWith('https://'))
                ? Image.network(answer.pictureOriginalPath)
                : Image.asset(answer.pictureOriginalPath),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Center(child: const Text('閉じる')),
              ),
            ],
          ),
        ),
        if (answer.isCorrect)
          Positioned(
            child: LottieAnimation(
              assetPath: 'assets/images/lottie_animation.json',
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
      ]);
    },
  );
}
