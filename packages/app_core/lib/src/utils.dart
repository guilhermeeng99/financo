import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Future<void> fileSaver({
    required String fileName,
    required List<int> excelBytes,
  }) async {
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(excelBytes),
      mimeType: MimeType.microsoftExcel,
    );
  }

  static Future<void> urlLaunch(String urlAux) async {
    final url0 = Uri.parse(urlAux);

    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }

  static void emailLaunch() {
    const email = 'support@capycare.com';
    const subject = 'Feedback - CapyCare App';

    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({'subject': subject}),
    );
    urlLaunch(emailLaunchUri.toString());
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
