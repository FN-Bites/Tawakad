import 'package:app_links/app_links.dart';

class DeepLinkData {
  final String mode;
  final String oobCode;

  DeepLinkData({
    required this.mode,
    required this.oobCode,
  });
}

class DeepLinkService {

  final AppLinks _appLinks = AppLinks();

  DeepLinkData? _extractData(Uri uri) {

    String? mode = uri.queryParameters['mode'];
    String? code = uri.queryParameters['oobCode'];

    // حالة Firebase dynamic link
    if (mode == null || code == null) {

      final nested = uri.queryParameters['link'];

      if (nested != null) {

        final innerUri = Uri.parse(nested);

        mode = innerUri.queryParameters['mode'];
        code = innerUri.queryParameters['oobCode'];

      }

    }

    if (mode != null && code != null) {
      return DeepLinkData(
        mode: mode,
        oobCode: code,
      );
    }

    return null;
  }

  Future<DeepLinkData?> getInitialLinkData() async {

    final uri = await _appLinks.getInitialLink();

    if (uri == null) return null;

    return _extractData(uri);
  }

  void listenForLinks(Function(DeepLinkData data) onData) {

    _appLinks.uriLinkStream.listen((uri) {

      final data = _extractData(uri);

      if (data != null) {
        onData(data);
      }

    });

  }

}