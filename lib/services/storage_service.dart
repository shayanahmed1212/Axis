// Thin wrapper around [ImagePicker] for profile photo selection.
// Images are resized to 512px max and converted to a base64 data URI
// so they can be stored directly in Firestore without a cloud storage
// bucket — fine for small avatar images.
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
