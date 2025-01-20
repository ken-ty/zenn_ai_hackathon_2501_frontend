import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';

Future<List<Question>> fetchQuestions() async {
  final apiEndpoint = dotenv.env['API_ENDPOINT'];
  final response = await http.get(Uri.parse(apiEndpoint!));
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    final List<dynamic> questionsJson = jsonData['questions'];
    return questionsJson.map((json) => Question.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load questions');
  }
}
