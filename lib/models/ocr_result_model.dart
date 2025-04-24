import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:uuid/uuid.dart';

class OcrResult {
  final String uuid; // Generated from path
  final String path;
  final String filename;
  final String size;
  final int width;
  final int height;
  String text;

  OcrResult._({
    required this.uuid,
    required this.path,
    required this.text,
    required this.filename,
    required this.size,
    required this.width,
    required this.height,
  });

  factory OcrResult({
    required String path,
    String text = "",
  }) {
    final file = File(path);
    final filename = p.basename(path);

    // Generate UUID from path using UUID v5
    const namespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // DNS namespace
    final uuid = const Uuid().v5(namespace, path);

    String fileSize = '';
    int imageWidth = 0;
    int imageHeight = 0;

    try {
      int fsize = file.lengthSync();
      if (fsize < 1024) {
        fileSize = '$fsize B';
      } else if (fsize < 1024 * 1024) {
        fileSize = '${(fsize / 1024).toStringAsFixed(2)} KB';
      } else if (fsize < 1024 * 1024 * 1024) {
        fileSize = '${(fsize / (1024 * 1024)).toStringAsFixed(2)} MB';
      } else {
        fileSize = '${(fsize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
      }
      final sizeResult = ImageSizeGetter.getSizeResult(FileInput(file));
      imageWidth = sizeResult.size.width;
      imageHeight = sizeResult.size.height;
    } on FileSystemException {
      print('Error accessing file: $path');
    } catch (e) {
      print('Error retrieving image metadata: $e');
    }

    return OcrResult._(
      uuid: uuid,
      path: path,
      text: text,
      filename: filename,
      size: fileSize,
      width: imageWidth,
      height: imageHeight,
    );
  }

  OcrResult changeText({String? text}) {
    return OcrResult._(
      uuid: uuid, // Preserve same UUID
      path: path,
      text: text ?? this.text,
      filename: filename,
      size: size,
      width: width,
      height: height,
    );
  }
}