import 'package:flutter/material.dart';

class ImageDisplay extends StatefulWidget {
  final VoidCallback? onTap;
  final Size? screenSize;
  final String path;

  const ImageDisplay(
      {super.key,
      required this.onTap,
      required this.screenSize,
      required this.path});

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  Size? _currentScreenSize;

  @override
  initState() {
    super.initState();
    _currentScreenSize = widget.screenSize;
  }

  @override
  void didUpdateWidget(covariant ImageDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenSize != widget.screenSize) {
      setState(() {
        _currentScreenSize = widget.screenSize;
      });
    }
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        _currentScreenSize?.width ?? MediaQuery.of(context).size.width;
    final screenHeight =
        _currentScreenSize?.height ?? MediaQuery.of(context).size.height;

    if (widget.path.isEmpty) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: widget.onTap == null ? null : widget.onTap!,
      child: _isNetworkImage(widget.path)
          ? Image.network(
              widget.path,
              width: screenWidth * 0.4,
              height: screenHeight * 0.4,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('画像読み込みエラー'));
              },
            )
          : Image.asset(
              widget.path,
              width: screenWidth * 0.4,
              height: screenHeight * 0.4,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('デバッグ画像読み込みエラー'));
              },
            ),
    );
  }
}
