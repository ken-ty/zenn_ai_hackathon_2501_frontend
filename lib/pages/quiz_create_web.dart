import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<Uint8List?> pickImageWeb() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    return result.files.first.bytes;
  } catch (e) {
    return null;
  }
}
