import 'package:url_launcher/url_launcher_string.dart';

Future<bool> openExternalUrl(String url) async {
  return launchUrlString(url, mode: LaunchMode.externalApplication);
}
