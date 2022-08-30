import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
