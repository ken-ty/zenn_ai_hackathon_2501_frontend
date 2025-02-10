import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/utils/logger.dart';

import '../models/quiz.dart';

class GamePage extends StatefulWidget {
  final List<Quiz> quizzes;
  final bool isHardMode;

  const GamePage({
    super.key,
    required this.quizzes,
    required this.isHardMode,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _currentQuizIndex = 0;
  int _correctAnswers = 0;
  bool _hasAnswered = false;
  String? _selectedAnswer;
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    AppLogger.info('ゲーム開始: ${widget.quizzes.length}問のクイズ');
  }

  @override
  void dispose() {
    _hasAnswered = true; // 非同期処理のキャンセル用フラグ
    super.dispose();
  }

  Quiz get currentQuiz => widget.quizzes[_currentQuizIndex];

  Future<void> _handleAnswer(String answer) async {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
    });

    final isCorrect = currentQuiz.isCorrectAnswer(answer);
    if (isCorrect) {
      setState(() {
        _correctAnswers++;
      });
    }

    if (!mounted) return;

    final isLastQuiz = _currentQuizIndex == widget.quizzes.length - 1;
    final message = isCorrect ? '正解！' : 'おしい！';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(message),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isCorrect ? '素晴らしい判断です！' : 'その解釈も面白いですね！'),
            const SizedBox(height: 16),
            const Text('作者の解釈:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(currentQuiz.authorInterpretation!),
            const SizedBox(height: 8),
            const Text('AIの解釈:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(currentQuiz.aiInterpretation!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isLastQuiz) {
                _showGameResult();
              } else {
                setState(() {
                  _currentQuizIndex++;
                  _hasAnswered = false;
                  _selectedAnswer = null;
                  _imageKey = UniqueKey();
                });
              }
            },
            child: Text(isLastQuiz ? '結果を見る' : '次へ'),
          ),
        ],
      ),
    );
  }

  void _showGameResult() {
    if (!mounted) return;
    Navigator.pop(context, _correctAnswers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('クイズ ${_currentQuizIndex + 1}/${widget.quizzes.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '正解数: $_correctAnswers',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  currentQuiz.imageUrl ??
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
                            value: loadingProgress.expectedTotalBytes != null
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
                    AppLogger.error('画像読み込みエラー: $error\nスタックトレース: $stackTrace');
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
                          Text('画像を読み込めませんでした\nURL: ${currentQuiz.imageUrl}'),
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
            const SizedBox(height: 24),
            const Text(
              'この作品についての解釈として正しいものはどちらでしょうか？',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...currentQuiz.interpretations.map((interpretation) {
              final isSelected = _selectedAnswer == interpretation;
              final isCorrect =
                  _hasAnswered && currentQuiz.isCorrectAnswer(interpretation);
              final isWrong = _hasAnswered && isSelected && !isCorrect;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed:
                      _hasAnswered ? null : () => _handleAnswer(interpretation),
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
    );
  }
}
