import 'package:flutter/services.dart';

class ExternalUrlOpener {
  const ExternalUrlOpener._();

  static const MethodChannel _channel = MethodChannel(
    'open_tavern/external_url',
  );

  static Future<bool> open(String url) async {
    final opened = await _channel.invokeMethod<bool>('openUrl', url);
    return opened ?? false;
  }
}
