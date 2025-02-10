import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zenn_ai_hackathon_2501_frontend/utils/logger.dart';

import '../models/quiz.dart';

class QuizService {
  final String baseUrl;

  QuizService()
      : baseUrl = dotenv.env['API_ENDPOINT'] ?? 'http://localhost:8080';

  // クイズ一覧の取得
  Future<List<Quiz>> getQuizzes() async {
    try {
      AppLogger.info('APIリクエスト開始: $baseUrl/quizzes');
      final response = await http.get(
        Uri.parse('$baseUrl/quizzes'),
        headers: {
          'Accept': 'application/json',
        },
      );

      AppLogger.info('APIレスポンス受信: ${response.statusCode}');
      AppLogger.info('レスポンスボディ: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        AppLogger.info('デコードされたレスポンス: $decodedBody');
        final List<dynamic> jsonList = json.decode(decodedBody);
        AppLogger.info('JSONデコード完了: ${jsonList.length}件のクイズデータ');
        final quizzes = jsonList.map((json) => Quiz.fromJson(json)).toList();
        AppLogger.info('Quizオブジェクトへの変換完了: ${quizzes.length}件');
        return quizzes;
      } else {
        AppLogger.info('APIエラー: ${response.statusCode}');
        AppLogger.info('エラーレスポンス: ${response.body}');
        throw Exception('Failed to load quizzes: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.info('例外発生: $e');
      if (e is FormatException) {
        AppLogger.info('JSONパースエラー');
      }
      throw Exception('Failed to load quizzes: $e');
    }
  }

  // 個別のクイズ取得
  Future<Quiz> getQuiz(String id) async {
    try {
      AppLogger.info('クイズ詳細の取得開始: $id');
      final response = await http.get(
        Uri.parse('$baseUrl/quizzes/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      AppLogger.info('APIレスポンス: ${response.statusCode}');
      AppLogger.info('レスポンスボディ: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        AppLogger.info('デコードされたレスポンス: $decodedBody');

        final json = jsonDecode(decodedBody);
        if (json == null) {
          throw Exception('APIレスポンスが不正です');
        }

        final quiz = Quiz.fromJson(json);

        // 必要なデータが揃っているか確認
        if (quiz.authorInterpretation == null ||
            quiz.aiInterpretation == null) {
          AppLogger.error('クイズデータが不完全: ${quiz.toJson()}');
          throw Exception('クイズの解釈データが不完全です');
        }

        return quiz;
      } else {
        AppLogger.error('APIエラー: ${response.statusCode} - ${response.body}');
        throw Exception('クイズの取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('クイズ詳細の取得でエラー発生: $e');
      rethrow;
    }
  }

  // 新しいクイズのアップロード
  Future<QuizUploadResponse> uploadQuiz({
    required String filePath,
    required String interpretation,
  }) async {
    try {
      // Base64データからバイナリに変換
      final imageData = base64Decode(filePath.split(',')[1]);

      // バウンダリの生成
      final boundary =
          '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';

      // リクエストボディの構築
      final body = <int>[];

      // ファイルパートの追加
      body.addAll(utf8.encode('\r\n--$boundary\r\n'));
      body.addAll(utf8.encode(
          'Content-Disposition: form-data; name="file"; filename="image.png"\r\n'));
      body.addAll(utf8.encode('Content-Type: image/png\r\n\r\n'));
      body.addAll(imageData);

      // 解釈テキストの追加
      body.addAll(utf8.encode('\r\n--$boundary\r\n'));
      body.addAll(utf8.encode(
          'Content-Disposition: form-data; name="interpretation"\r\n\r\n'));
      body.addAll(utf8.encode(interpretation));
      body.addAll(utf8.encode('\r\n--$boundary--\r\n'));

      // リクエストの送信
      final response = await http.post(
        Uri.parse('$baseUrl/upload'),
        headers: {
          'Content-Type': 'multipart/form-data; boundary=$boundary',
          'Accept': '*/*',
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        AppLogger.info('Error response: ${response.body}');
        throw Exception('Failed to upload quiz: ${response.body}');
      }

      // UTF-8でデコード
      final decodedBody = utf8.decode(response.bodyBytes);
      AppLogger.info('デコードされたレスポンス: $decodedBody');
      return QuizUploadResponse.fromJson(jsonDecode(decodedBody));
    } catch (e) {
      AppLogger.info('Upload error: $e');
      throw Exception('Failed to upload quiz: ${e.toString()}');
    }
  }
}
