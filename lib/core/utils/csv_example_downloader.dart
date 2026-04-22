import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:financo/core/utils/web_file_download.dart'
    if (dart.library.js_interop) 'package:financo/core/utils/web_file_download_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<bool> downloadCsvExample({
  required String assetPath,
  required String fileName,
  required String dialogTitle,
}) async {
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();

  if (kIsWeb) {
    triggerBrowserDownload(bytes, fileName, 'text/csv');
    return true;
  }

  final savedPath = await FilePicker.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    bytes: bytes,
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (savedPath == null) return false;
  await File(savedPath).writeAsBytes(bytes);
  return true;
}
