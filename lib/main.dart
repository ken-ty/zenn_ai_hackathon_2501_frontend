import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';
import 'package:zenn_ai_hackathon_2501_frontend/services/question_service.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/image_display.dart';

Future main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (error) {
    print("Error loading .env file: $error");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Pop-up text
  void _popUpText(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: AlertDialog(
                title: Text(
          text,
          textAlign: TextAlign.center,
        )));
      },
    );
  }

  // Improved _processQuestions to handle potential errors and data structure
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
                                onTap: () {
                                  _popUpText(firstAnswer.pictureTitle);
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
                                onTap: () {
                                  _popUpText(secondAnswer.pictureTitle);
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
