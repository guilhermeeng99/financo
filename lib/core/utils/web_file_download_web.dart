import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void triggerBrowserDownload(Uint8List bytes, String fileName, String mimeType) {
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body!.append(anchor);
  anchor
    ..click()
    ..remove();
  web.URL.revokeObjectURL(url);
}

void triggerBrowserUrlDownload(String url, String fileName) {
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body!.append(anchor);
  anchor
    ..click()
    ..remove();
}
