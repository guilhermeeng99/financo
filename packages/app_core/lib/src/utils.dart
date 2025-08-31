import 'package:app_widgets/app_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Future<void> urlLaunch(String urlAux) async {
    final url0 = Uri.parse(urlAux);

    try {
      await launchUrl(url0);
    } catch (e) {
      logger.e('Could not launch $url0: $e');
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
