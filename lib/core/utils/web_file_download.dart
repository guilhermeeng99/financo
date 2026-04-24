import 'dart:typed_data';

void triggerBrowserDownload(Uint8List bytes, String fileName, String mimeType) {
  throw UnsupportedError(
    'triggerBrowserDownload is only supported on Flutter Web.',
  );
}

void triggerBrowserUrlDownload(String url, String fileName) {
  throw UnsupportedError(
    'triggerBrowserUrlDownload is only supported on Flutter Web.',
  );
}
