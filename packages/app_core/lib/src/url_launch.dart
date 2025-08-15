import 'package:url_launcher/url_launcher.dart';

Future<void> urlLaunch(String urlAux) async {
  final url0 = Uri.parse(urlAux);

  if (!await launchUrl(url0)) {
    throw Exception('Could not launch $url0');
  }
}
