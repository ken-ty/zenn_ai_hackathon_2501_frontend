import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../utils/logger.dart';

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;

  const QuizPlayPage({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  bool _hasAnswered = false;
  String? _selectedAnswer;
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    AppLogger.info('クイズプレイ開始: ${widget.quiz.id}');
  }

  Future<void> _handleAnswer(String answer) async {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
    });

    final isCorrect = widget.quiz.isCorrectAnswer(answer);
    final message = isCorrect
        ? [
            '素晴らしい！正解です！👏',
            'あなたの芸術的センスは素晴らしいですね。',
            '作品の本質を見抜く目を持っていますね！',
          ][DateTime.now().microsecond % 3]
        : [
            'おしい！不正解です。でも素敵な解釈ですね！',
            '違いましたが、その解釈も面白い視点ですね！',
            '惜しい！その発想も素晴らしいです！',
          ][DateTime.now().microsecond % 3];

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? '正解！' : 'おしい！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text('投稿者の解釈:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.quiz.authorInterpretation!),
            const SizedBox(height: 8),
            const Text('AIの解釈:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.quiz.aiInterpretation!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, isCorrect);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final contentWidth = isDesktop ? 600.0 : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('クイズ'),
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.quiz.imageUrl ??
                            'https://placehold.jp/3d4070/ffffff/600x800.png?text=NO%20IMAGE',
                        fit: BoxFit.contain,
                        headers: const {
                          'Accept': 'image/jpeg, image/png, image/*',
                          'Access-Control-Allow-Origin': '*',
                          'Access-Control-Allow-Methods': 'GET',
                          'Cache-Control': 'no-cache',
                          'Pragma': 'no-cache',
                          'Expires': '0',
                        },
                        cacheWidth: 800,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                const Text('画像を読み込み中...'),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          AppLogger.error(
                              '画像読み込みエラー: $error\nスタックトレース: $stackTrace');
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                const Text('画像を読み込めませんでした'),
                                const SizedBox(height: 4),
                                Text(
                                  widget.quiz.imageUrl ?? 'URL not found',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _imageKey = UniqueKey();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('再試行'),
                                ),
                              ],
                            ),
                          );
                        },
                        key: _imageKey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'この作品についての解釈として正しいものはどちらでしょうか？',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ...widget.quiz.interpretations.map((interpretation) {
                          final isSelected = _selectedAnswer == interpretation;
                          final isCorrect = _hasAnswered &&
                              widget.quiz.isCorrectAnswer(interpretation);
                          final isWrong =
                              _hasAnswered && isSelected && !isCorrect;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton(
                              onPressed: _hasAnswered
                                  ? null
                                  : () => _handleAnswer(interpretation),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                backgroundColor: isCorrect
                                    ? Colors.green
                                    : isWrong
                                        ? Colors.red
                                        : null,
                              ),
                              child: Text(
                                interpretation,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
