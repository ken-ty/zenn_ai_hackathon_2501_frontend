import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenn_ai_hackathon_2501_frontend/utils/logger.dart';

import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz_create_page.dart';
import 'quiz_play_page.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage>
    with SingleTickerProviderStateMixin {
  final _quizService = QuizService();
  bool _isLoading = false;
  List<Quiz> _quizzes = [];
  final Set<String> _completedQuizIds = <String>{};
  final _dateFormat = DateFormat('yyyy/MM/dd HH:mm');
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _dateFormat.format(date.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _loadQuizzes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info('クイズの読み込みを開始します');
      final quizzes = await _quizService.getQuizzes();
      AppLogger.info('取得したクイズ数: ${quizzes.length}');

      // 新しい順に並び替え
      quizzes.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      if (mounted) {
        setState(() {
          _quizzes = quizzes;
        });
      }
      AppLogger.info('クイズの読み込みが完了しました');
    } catch (e) {
      AppLogger.error('クイズの読み込みエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('クイズの読み込みに失敗しました')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshQuizzes() async {
    AppLogger.info('クイズ一覧を更新します');
    await _loadQuizzes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クイズ一覧を更新しました')),
      );
    }
  }

  Future<void> _playQuiz(Quiz quiz) async {
    try {
      setState(() => _isLoading = true);
      AppLogger.info('クイズ詳細の読み込みを開始: ${quiz.id}');

      final detailedQuiz = await _quizService.getQuiz(quiz.id);

      if (detailedQuiz.authorInterpretation == null ||
          detailedQuiz.aiInterpretation == null) {
        throw Exception('クイズの解釈データが不完全です');
      }

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => QuizPlayPage(quiz: detailedQuiz),
        ),
      );

      if (result == true) {
        setState(() {
          _completedQuizIds.add(quiz.id);
        });
      }
    } catch (e) {
      AppLogger.error('クイズ詳細の読み込みに失敗: $e');
      if (!mounted) return;

      String errorMessage = 'クイズの読み込みに失敗しました。';
      if (e.toString().contains('不完全です')) {
        errorMessage = 'クイズの解釈データが不完全です。';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final contentWidth = isDesktop ? 600.0 : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'AI Art Quiz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -2 * _animation.value),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withAlpha(76),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizCreatePage(),
                ),
              );

              if (result == true) {
                await _refreshQuizzes();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'クイズを作成',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16.0 : 8.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _quizzes.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'クイズがありません',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              itemCount: _quizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = _quizzes[index];
                                final isCompleted =
                                    _completedQuizIds.contains(quiz.id);
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF6B4EFF),
                                            Color(0xFFFF6B4E),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.palette_outlined,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      'クイズ ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '作成日: ${_formatDate(quiz.createdAt ?? '')}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: isCompleted
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'クリア',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0EBFF),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'チャレンジ',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                    onTap: () => _playQuiz(quiz),
                                  ),
                                );
                              },
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _refreshQuizzes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('更新'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
