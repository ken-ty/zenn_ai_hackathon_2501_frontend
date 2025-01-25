import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';
import 'package:zenn_ai_hackathon_2501_frontend/pages/game_result_page.dart';
import 'package:zenn_ai_hackathon_2501_frontend/services/question_service.dart';
import 'package:zenn_ai_hackathon_2501_frontend/utils/popup_utils.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/image_display.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/lottie_animation.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<GamePage> createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  Future<Question?> _processQuestions(int id) async {
    try {
      List<Question> questions = await fetchQuestions();
      return questions[id];
    } catch (error) {
      print('Error fetching questions: $error');
      return null; // Handle errors gracefully
    }
  }

  int _totalQuestions = 0;
  int _trueAnswers = 0;

  @override
  Widget build(BuildContext context) {
    int id = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text(widget.title),
      ),
      body: Center(
        child: StatefulBuilder(
          // StatefulBuilderで囲む
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<Question?>(
                  future: _processQuestions(id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final question = snapshot.data!;
                      final firstAnswer = question.answers[0];
                      final secondAnswer = question.answers[1];
                      return Column(
                        children: [
                          Text(question.title),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ImageDisplay(
                                onTap: () async {
                                  await showPopup(context, firstAnswer);
                                  _totalQuestions += 1;
                                  if (firstAnswer.isCorrect) {
                                    LottieAnimation(
                                      assetPath: 'assets/lottie_animation.json',
                                    );
                                    _trueAnswers += 1;
                                  }
                                  setState(() {
                                    id++;
                                  });
                                },
                                screenSize: MediaQuery.of(context).size,
                                path: firstAnswer.pictureResizePath,
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.05),
                              ImageDisplay(
                                onTap: () async {
                                  await showPopup(context, secondAnswer);
                                  _totalQuestions += 1;
                                  if (secondAnswer.isCorrect) {
                                    _trueAnswers += 1;
                                  }
                                  setState(() {
                                    id++;
                                  });
                                },
                                screenSize: MediaQuery.of(context).size,
                                path: secondAnswer.pictureResizePath,
                              ),
                            ],
                          ),
                          Text(question.description),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Display error message
                    } else if (snapshot.data == null && _totalQuestions > 0) {
                      // 全ての質問が終わった場合
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => GameResultPage(
                                  trueAnswers: _trueAnswers,
                                  totalQuestions: _totalQuestions)),
                          (Route<dynamic> route) => false,
                        );
                      });
                      return const CircularProgressIndicator();
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
