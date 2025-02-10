import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenn_ai_hackathon_2501_frontend/utils/logger.dart';

import '../services/quiz_service.dart';

class QuizCreatePage extends StatefulWidget {
  const QuizCreatePage({super.key});

  @override
  State<QuizCreatePage> createState() => _QuizCreatePageState();
}

class _QuizCreatePageState extends State<QuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _interpretationController = TextEditingController();
  String? _base64Image;
  bool _isLoading = false;
  bool _isCancelled = false;

  @override
  void dispose() {
    _isCancelled = true;
    _interpretationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        await _pickImageWeb();
      } else {
        await _pickImageMobile();
      }
    } catch (e) {
      AppLogger.error('画像選択エラー: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像の選択に失敗しました')),
      );
    }
  }

  Future<void> _pickImageWeb() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) return;

      setState(() {
        _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    } catch (e) {
      AppLogger.error('Web画像選択エラー: $e');
      rethrow;
    }
  }

  Future<void> _pickImageMobile() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    } catch (e) {
      AppLogger.error('モバイル画像選択エラー: $e');
      rethrow;
    }
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate() || _base64Image == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quizService = QuizService();
      final response = await quizService.uploadQuiz(
        filePath: _base64Image!,
        interpretation: _interpretationController.text,
      );

      AppLogger.info('クイズ作成成功: ${response.id}');

      if (!mounted) return;

      final shouldReturn = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('クイズ作成完了'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '作成されたクイズの情報：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('クイズID: ${response.id}'),
                const SizedBox(height: 16),
                const Text(
                  '投稿者の解釈：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(response.authorInterpretation),
                const SizedBox(height: 16),
                const Text(
                  'AIの解釈：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(response.aiInterpretation),
                const SizedBox(height: 16),
                const Text(
                  '作成日時：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(response.createdAt.toLocal().toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (shouldReturn == true) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('クイズを作成しました')),
        );
      }
    } catch (e) {
      AppLogger.error('クイズ作成エラー: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クイズの作成に失敗しました')),
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
    final horizontalPadding =
        isDesktop ? (screenWidth - contentWidth) / 2 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('クイズを作成'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: isDesktop ? 400 : 300,
                          ),
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _base64Image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(
                                            _base64Image!.split(',')[1]),
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('画像を選択',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _interpretationController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: '作品の解釈',
                            hintText: 'この作品についてのあなたの解釈を書いてください',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '解釈を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _createQuiz,
                            child: const Text('作成'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
