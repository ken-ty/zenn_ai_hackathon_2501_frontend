import 'package:zenn_ai_hackathon_2501_frontend/models/image_origin.dart';

class ImageData {
  final String? path;
  final ImageOrigin origin;

  ImageData({this.path, this.origin = ImageOrigin.madebyhuman});
}
