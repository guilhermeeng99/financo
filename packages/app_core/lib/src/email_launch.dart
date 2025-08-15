import 'package:app_core/app_core.dart';

void emailLaunch() {
  const email = 'support@capycare.com';
  const subject = 'Feedback - CapyCare App';

  final emailLaunchUri = Uri(
    scheme: 'mailto',
    path: email,
    query: encodeQueryParameters({'subject': subject}),
  );
  urlLaunch(emailLaunchUri.toString());
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}
