import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum FileParentType {
  imageUrl,
  imageGallery,
  imageCamera,
  other,
}

class FileHelper {
  static final FileHelper helper = FileHelper._();
  FileHelper._();

  Directory? temporaryDirectory;
  Future<File> writeToFile(String filename, dynamic bytes, FileParentType parentTypes) async {
    assert(bytes is Uint8List || bytes is ByteData);

    if (bytes is ByteData) {
      bytes = bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      );
    }

    File file = await constructFile(filename, parentTypes);
    return file.writeAsBytes(bytes);
  }

  Future<File> constructFile(String filename, FileParentType parentTypes) async {
    String parentName = getParentName(parentTypes);
    temporaryDirectory ??= await getTemporaryDirectory();
    File file = File('${temporaryDirectory!.path}/$parentName/$filename');
    if (!file.parent.existsSync()) await file.parent.create(recursive: true);
    return file;
  }

  Future<File?> getCachedFile(String imagePath, FileParentType parentTypes) async {
    String parentName = getParentName(parentTypes);
    temporaryDirectory ??= await getTemporaryDirectory();
    File file = File('${temporaryDirectory!.path}/$parentName/$imagePath');
    if (await file.exists()) return file;
    return null;
  }

  Future<List<File>> listAllImages() async {
    temporaryDirectory ??= await getTemporaryDirectory();
    final parentPath = Directory('${temporaryDirectory!.path}/images');
    final result = parentPath.listSync(recursive: true);
    return result.whereType<File>().toList();
  }

  String getParentName(FileParentType parentTypes) {
    String parentName = '';

    switch (parentTypes) {
      case FileParentType.imageUrl:
        parentName = 'images/url';
        break;
      case FileParentType.imageGallery:
        parentName = 'images/gallery';
        break;
      case FileParentType.imageCamera:
        parentName = 'images/camera';
        break;
      case FileParentType.other:
        parentName = 'other';
        break;
    }

    return parentName;
  }
}
