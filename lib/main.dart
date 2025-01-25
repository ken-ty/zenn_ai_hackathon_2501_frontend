import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zenn_ai_hackathon_2501_frontend/pages/game_list_page.dart';

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
      home: const GameListPage(),
    );
  }
}
