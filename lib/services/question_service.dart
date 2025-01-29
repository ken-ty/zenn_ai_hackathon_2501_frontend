import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:zenn_ai_hackathon_2501_frontend/models/question.dart';

Future<List<Question>> fetchQuestions() async {
  final String jsonString = await rootBundle.loadString('assets/data.json');
  final jsonData = Map<String, dynamic>.from(jsonDecode(jsonString));
  final List<dynamic> questionsJson = jsonData['questions'];
  // return Map<String, dynamic>.from(jsonDecode(jsonString));

  return questionsJson.map((json) => Question.fromJson(json)).toList();

  // final apiEndpoint = dotenv.env['API_ENDPOINT'];
  // try {
  //   final response = await http.get(Uri.parse(apiEndpoint!));
  //   final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
  //   final List<dynamic> questionsJson = jsonData['questions'];
  //   return questionsJson.map((json) => Question.fromJson(json)).toList();
  // } catch (error) {
  //   final data = await loadJsonData();
  //   return data.map((json) => Question.fromJson(json)).toList();
  //   // throw Exception('Failed to load questions');
  // }
}

Future<Map<String, dynamic>> loadJsonData() async {
  final String jsonString = await rootBundle.loadString('assets/data.json');
  return Map<String, dynamic>.from(jsonDecode(jsonString));
}
