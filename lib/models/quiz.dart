import 'package:zenn_ai_hackathon_2501_frontend/utils/logger.dart';

class Quiz {
  final String id;
  String? imageUrl;
  String? authorInterpretation;
  String? aiInterpretation;
  String? createdAt;
  List<String>? _shuffledInterpretations;

  Quiz({
    required this.id,
    this.imageUrl,
    this.authorInterpretation,
    this.aiInterpretation,
    this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    AppLogger.info('Quiz.fromJson 入力: $json');

    final quiz = Quiz(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String?,
      authorInterpretation: json['author_interpretation'] as String?,
      aiInterpretation: json['ai_interpretation'] as String?,
      createdAt: json['created_at'] as String?,
    );

    AppLogger.info('Quiz生成完了: ${quiz.toJson()}');
    return quiz;
  }

  List<String> get interpretations {
    if (authorInterpretation == null || aiInterpretation == null) {
      return [];
    }

    _shuffledInterpretations ??= [authorInterpretation!, aiInterpretation!]
      ..shuffle();

    return List<String>.from(_shuffledInterpretations!);
  }

  bool isCorrectAnswer(String selectedInterpretation) {
    if (authorInterpretation == null) {
      return false;
    }
    return selectedInterpretation == authorInterpretation;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'author_interpretation': authorInterpretation,
      'ai_interpretation': aiInterpretation,
      'created_at': createdAt,
    };
  }
}

class QuizUploadResponse {
  final String id;
  final String imageUrl;
  final String authorInterpretation;
  final String aiInterpretation;
  final DateTime createdAt;

  QuizUploadResponse({
    required this.id,
    required this.imageUrl,
    required this.authorInterpretation,
    required this.aiInterpretation,
    required this.createdAt,
  });

  factory QuizUploadResponse.fromJson(Map<String, dynamic> json) {
    return QuizUploadResponse(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      authorInterpretation: json['author_interpretation'] as String,
      aiInterpretation: json['ai_interpretation'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
