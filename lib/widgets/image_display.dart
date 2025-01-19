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

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        _currentScreenSize?.width ?? MediaQuery.of(context).size.width;
    final screenHeight =
        _currentScreenSize?.height ?? MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        widget.onTap!();
      },
      child: Image.asset(widget.path,
          width: screenWidth * 0.4, height: screenHeight * 0.4),
    );
  }
}
