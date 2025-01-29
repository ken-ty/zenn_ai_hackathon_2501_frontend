import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';
import 'package:zenn_ai_hackathon_2501_frontend/pages/game_result_page.dart';
import 'package:zenn_ai_hackathon_2501_frontend/services/question_service.dart';
import 'package:zenn_ai_hackathon_2501_frontend/utils/popup_utils.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/image_display.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _totalQuestions = 0;
  int _trueAnswers = 0;
  int _currentQuestionId = 0;

  Future<Question?> _fetchQuestion(int id) async {
    try {
      final questions = await fetchQuestions();
      return questions[id];
    } catch (error) {
      print('Error fetching questions: $error');
      return null;
    }
  }

  void _handleAnswerTap(Answer answer) async {
    await showPopup(context, answer);
    setState(() {
      _totalQuestions++;
      if (answer.isCorrect) _trueAnswers++;
      _currentQuestionId++;
    });
  }

  void _navigateToResultPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => GameResultPage(
          trueAnswers: _trueAnswers,
          totalQuestions: _totalQuestions,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<Question?>(
          future: _fetchQuestion(_currentQuestionId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null && _totalQuestions > 0) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _navigateToResultPage());
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              final question = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(question.title),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: question.answers
                        .map((answer) => ImageDisplay(
                              onTap: () => _handleAnswerTap(answer),
                              screenSize: MediaQuery.of(context).size,
                              path: answer.pictureResizePath,
                            ))
                        .toList(),
                  ),
                  Text(question.description),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
