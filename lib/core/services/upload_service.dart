import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

class UploadService {
  UploadService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadReviewImage({
    required XFile file,
    required String userId,
  }) async {
    final fileBytes = await file.readAsBytes();
    final String? mimeType = lookupMimeType(file.name, headerBytes: fileBytes);

    Uint8List data = fileBytes;
    if (fileBytes.lengthInBytes > 1 * 1024 * 1024) {
      final compressed = await FlutterImageCompress.compressWithList(
        fileBytes,
        quality: 75,
        minWidth: 1280,
      );
      data = Uint8List.fromList(compressed);
    }

    final String ext = _extensionFromMime(mimeType) ?? 'jpg';
    final String id = const Uuid().v4();
    final String path = 'reviews/$userId/$id.$ext';

    final ref = _storage.ref().child(path);
    final meta = SettableMetadata(contentType: mimeType ?? 'image/jpeg');
    final task = await ref.putData(data, meta);
    return await task.ref.getDownloadURL();
  }

  static String? _extensionFromMime(String? mime) {
    if (mime == null) return null;
    switch (mime) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      default:
        return null;
    }
  }
}
