import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/quiz_service.dart';
import '../utils/popup_utils.dart';
import 'quiz_create_web.dart' if (dart.library.io) 'quiz_create_mobile.dart';

class QuizCreatePage extends StatefulWidget {
  const QuizCreatePage({super.key});

  @override
  State<QuizCreatePage> createState() => _QuizCreatePageState();
}

class _QuizCreatePageState extends State<QuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _interpretationController = TextEditingController();
  final _quizService = QuizService();
  Uint8List? _imageData;
  bool _isLoading = false;
  bool _isCancelled = false;

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        _imageData = await pickImageWeb();
      } else {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          _imageData = await image.readAsBytes();
        }
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, '画像の選択に失敗しました');
      }
    }
  }

  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate() || _imageData == null) {
      if (!mounted) return;
      showErrorSnackBar(context, '画像とコメントを入力してください');
      return;
    }

    setState(() {
      _isLoading = true;
      _isCancelled = false;
    });

    try {
      if (_isCancelled) {
        if (mounted) {
          setState(() => _isLoading = false);
          showErrorSnackBar(context, 'クイズの作成をキャンセルしました');
        }
        return;
      }
      final base64Image = base64Encode(_imageData!);

      if (_isCancelled) {
        if (mounted) {
          setState(() => _isLoading = false);
          showErrorSnackBar(context, 'クイズの作成をキャンセルしました');
        }
        return;
      }
      final response = await _quizService.uploadQuiz(
        filePath: 'data:image/png;base64,$base64Image',
        interpretation: _interpretationController.text,
      );

      if (_isCancelled || !mounted) {
        if (_isCancelled && mounted) {
          setState(() => _isLoading = false);
          showErrorSnackBar(context, 'クイズの作成をキャンセルしました');
        }
        return;
      }

      final shouldReturn = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (!didPop) {
              _isCancelled = true;
              Navigator.of(context).pop(false);
              showErrorSnackBar(context, 'クイズの作成をキャンセルしました');
            }
          },
          child: AlertDialog(
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
                    '作者の解釈：',
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
        ),
      );

      if (_isCancelled || !mounted) {
        if (_isCancelled && mounted) {
          setState(() => _isLoading = false);
          showErrorSnackBar(context, 'クイズの作成をキャンセルしました');
        }
        return;
      }
      if (shouldReturn == true) {
        Navigator.pop(context, true);
      }

      showSuccessSnackBar(context, 'クイズを作成しました');
    } catch (e) {
      if (_isCancelled || !mounted) {
        if (_isCancelled && mounted) {
          setState(() => _isLoading = false);
          showErrorSnackBar(context, 'クイズの作成をキャンセルしました');
        }
        return;
      }
      showErrorSnackBar(context, 'クイズの作成に失敗しました: ${e.toString()}');
    } finally {
      if (mounted && !_isCancelled) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isCancelled = true;
    _interpretationController.dispose();
    super.dispose();
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
                              child: _imageData != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        _imageData!,
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
                            onPressed: _submitQuiz,
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
