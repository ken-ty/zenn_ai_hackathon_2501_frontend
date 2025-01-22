import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';

Future<void> showPopup(BuildContext context, Answer answer) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          answer.pictureTitle,
          textAlign: TextAlign.center,
        ),
        content: Image.network(answer.pictureOriginalPath),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Center(child: const Text('閉じる')),
          ),
        ],
      );
    },
  );
}
