import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class StorageService {
  Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    return picker.pickImage(source: source, imageQuality: 80, maxWidth: 512);
  }

  Future<String> imageToBase64(XFile image) async {
    final bytes = await image.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}
