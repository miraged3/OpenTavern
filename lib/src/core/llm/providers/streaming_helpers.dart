import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

const llmConnectTimeout = Duration(seconds: 15);
const llmReceiveTimeout = Duration(minutes: 5);

BaseOptions llmBaseOptions({
  required String baseUrl,
  Map<String, dynamic>? headers,
}) {
  return BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: llmConnectTimeout,
    receiveTimeout: llmReceiveTimeout,
    headers: headers,
  );
}

Stream<Map<String, dynamic>> decodeSseJson(ResponseBody responseBody) async* {
  await for (final line
      in utf8.decoder
          .bind(responseBody.stream)
          .transform(const LineSplitter())) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('data:')) {
      continue;
    }

    final payload = trimmed.substring(5).trim();
    if (payload.isEmpty || payload == '[DONE]') {
      continue;
    }

    final decoded = _tryDecodeJson(payload);
    if (decoded is Map<String, dynamic>) {
      yield decoded;
    }
  }
}

Object? _tryDecodeJson(String payload) {
  try {
    return jsonDecode(payload);
  } on FormatException {
    return null;
  }
}
