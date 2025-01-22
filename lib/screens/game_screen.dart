import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/main.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';
import 'package:zenn_ai_hackathon_2501_frontend/services/question_service.dart';
import 'package:zenn_ai_hackathon_2501_frontend/utils/popup_utils.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/image_display.dart';

class GameScreenState extends State<GameScreen> {
  Future<Question?> _processQuestions(int id) async {
    try {
      List<Question> questions = await fetchQuestions();
      return questions[id];
    } catch (error) {
      print('Error fetching questions: $error');
      return null; // Handle errors gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    int id = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    } else {
                      return const CircularProgressIndicator(); // Show loading indicator
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
