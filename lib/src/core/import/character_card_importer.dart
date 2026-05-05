import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../models/character.dart';

class CharacterImportResult {
  const CharacterImportResult({
    required this.character,
    required this.warnings,
  });

  final Character character;
  final List<String> warnings;
}

class CharacterCardImporter {
  const CharacterCardImporter();

  static const List<int> _pngSignature = <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ];

  CharacterImportResult importJson(
    String rawJson, {
    String? sourceUrl,
    String? sourceSite,
  }) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException(
        'Character card JSON top level must be an object',
      );
    }

    final json = Map<String, dynamic>.from(decoded);
    return _isDataCard(json)
        ? _importV2(json, rawJson, sourceUrl: sourceUrl, sourceSite: sourceSite)
        : _importV1(
            json,
            rawJson,
            sourceUrl: sourceUrl,
            sourceSite: sourceSite,
          );
  }

  CharacterImportResult importPng(
    Uint8List bytes, {
    String? sourceUrl,
    String? sourceSite,
  }) {
    if (!_hasPngSignature(bytes)) {
      throw const FormatException('Not a valid PNG file');
    }

    final metadata = _extractPngTextChunks(bytes);
    final embedded = metadata['chara'] ?? metadata['ccv3'];
    if (embedded == null || embedded.trim().isEmpty) {
      throw const FormatException(
        'Character card data not found in PNG (missing chara/ccv3 metadata)',
      );
    }

    final rawJson = _decodeEmbeddedCard(embedded);
    final result = importJson(
      rawJson,
      sourceUrl: sourceUrl,
      sourceSite: sourceSite,
    );

    return CharacterImportResult(
      character: result.character.copyWith(
        avatarImageBase64: base64Encode(bytes),
        sourceFormat: _isDataFormat(result.character.sourceFormat)
            ? CharacterImportFormat.pngV2
            : CharacterImportFormat.pngV1,
      ),
      warnings: result.warnings,
    );
  }

  bool _isDataCard(Map<String, dynamic> json) {
    return (json['spec'] == 'chara_card_v2' ||
            json['spec'] == 'chara_card_v3') &&
        json['data'] is Map;
  }

  bool _isDataFormat(CharacterImportFormat format) {
    return format == CharacterImportFormat.jsonV2 ||
        format == CharacterImportFormat.pngV2;
  }

  bool _hasPngSignature(Uint8List bytes) {
    if (bytes.length < _pngSignature.length) {
      return false;
    }

    for (var index = 0; index < _pngSignature.length; index++) {
      if (bytes[index] != _pngSignature[index]) {
        return false;
      }
    }
    return true;
  }

  Map<String, String> _extractPngTextChunks(Uint8List bytes) {
    final metadata = <String, String>{};
    final byteData = ByteData.sublistView(bytes);
    var offset = 8;

    while (offset + 12 <= bytes.length) {
      final length = byteData.getUint32(offset);
      final typeStart = offset + 4;
      final dataStart = offset + 8;
      final dataEnd = dataStart + length;
      final crcEnd = dataEnd + 4;
      if (crcEnd > bytes.length) {
        break;
      }

      final chunkType = ascii.decode(bytes.sublist(typeStart, typeStart + 4));
      final chunkData = bytes.sublist(dataStart, dataEnd);

      if (chunkType == 'tEXt') {
        final entry = _parseTextChunk(chunkData);
        if (entry != null) {
          metadata[entry.$1] = entry.$2;
        }
      } else if (chunkType == 'zTXt') {
        final entry = _parseCompressedTextChunk(chunkData);
        if (entry != null) {
          metadata[entry.$1] = entry.$2;
        }
      } else if (chunkType == 'iTXt') {
        final entry = _parseInternationalTextChunk(chunkData);
        if (entry != null) {
          metadata[entry.$1] = entry.$2;
        }
      }

      offset = crcEnd;
      if (chunkType == 'IEND') {
        break;
      }
    }

    return metadata;
  }

  (String, String)? _parseTextChunk(List<int> chunkData) {
    final separatorIndex = chunkData.indexOf(0);
    if (separatorIndex <= 0) {
      return null;
    }

    return (
      latin1.decode(chunkData.sublist(0, separatorIndex)),
      latin1.decode(chunkData.sublist(separatorIndex + 1)),
    );
  }

  (String, String)? _parseCompressedTextChunk(List<int> chunkData) {
    final keywordEnd = chunkData.indexOf(0);
    if (keywordEnd <= 0 || keywordEnd + 2 >= chunkData.length) {
      return null;
    }

    final keyword = latin1.decode(chunkData.sublist(0, keywordEnd));
    final compressionMethod = chunkData[keywordEnd + 1];
    if (compressionMethod != 0) {
      return null;
    }

    try {
      final value = latin1.decode(
        zlib.decode(chunkData.sublist(keywordEnd + 2)),
      );
      return (keyword, value);
    } catch (_) {
      return null;
    }
  }

  (String, String)? _parseInternationalTextChunk(List<int> chunkData) {
    final keywordEnd = chunkData.indexOf(0);
    if (keywordEnd <= 0 || keywordEnd + 5 >= chunkData.length) {
      return null;
    }

    final keyword = latin1.decode(chunkData.sublist(0, keywordEnd));
    final compressionFlag = chunkData[keywordEnd + 1];
    final compressionMethod = chunkData[keywordEnd + 2];
    if (compressionFlag != 0 && compressionMethod != 0) {
      return null;
    }

    var cursor = keywordEnd + 3;
    final languageEnd = chunkData.indexOf(0, cursor);
    if (languageEnd < 0) {
      return null;
    }

    cursor = languageEnd + 1;
    final translatedKeywordEnd = chunkData.indexOf(0, cursor);
    if (translatedKeywordEnd < 0) {
      return null;
    }

    final textBytes = chunkData.sublist(translatedKeywordEnd + 1);
    try {
      final decodedBytes = compressionFlag == 0
          ? textBytes
          : zlib.decode(textBytes);
      return (keyword, utf8.decode(decodedBytes));
    } catch (_) {
      return null;
    }
  }

  String _decodeEmbeddedCard(String embedded) {
    final trimmed = embedded.trim();
    if (trimmed.startsWith('{')) {
      return trimmed;
    }

    try {
      return utf8.decode(base64Decode(trimmed));
    } catch (_) {
      return trimmed;
    }
  }

  CharacterImportResult _importV1(
    Map<String, dynamic> json,
    String rawJson, {
    String? sourceUrl,
    String? sourceSite,
  }) {
    final warnings = _buildWarnings(json);
    final name = _stringValue(json['name']);
    final now = DateTime.now();

    return CharacterImportResult(
      character: Character(
        id: 'char-${now.microsecondsSinceEpoch}',
        name: name.isEmpty ? 'Unnamed Character' : name,
        description: _stringValue(json['description']),
        personality: _stringValue(json['personality']),
        scenario: _stringValue(json['scenario']),
        firstMessage: _stringValue(json['first_mes']),
        avatar: _avatarFallback(name),
        tags: const <String>[],
        exampleMessages: _stringValue(json['mes_example']),
        sourceFormat: CharacterImportFormat.jsonV1,
        sourceSite: sourceSite,
        sourceUrl: sourceUrl,
        importedAt: now,
        createdAt: now,
        updatedAt: now,
        rawCardJson: rawJson,
      ),
      warnings: warnings,
    );
  }

  CharacterImportResult _importV2(
    Map<String, dynamic> json,
    String rawJson, {
    String? sourceUrl,
    String? sourceSite,
  }) {
    final data = Map<String, dynamic>.from(json['data'] as Map);
    final warnings = _buildWarnings(data);
    final name = _stringValue(data['name']);
    final now = DateTime.now();

    return CharacterImportResult(
      character: Character(
        id: 'char-${now.microsecondsSinceEpoch}',
        name: name.isEmpty ? 'Unnamed Character' : name,
        description: _stringValue(data['description']),
        personality: _stringValue(data['personality']),
        scenario: _stringValue(data['scenario']),
        firstMessage: _stringValue(data['first_mes']),
        avatar: _avatarFallback(name),
        tags: _stringList(data['tags']),
        creator: _nullableString(data['creator']),
        creatorNotes: _nullableString(data['creator_notes']),
        systemPrompt: _nullableString(data['system_prompt']),
        postHistoryInstructions: _nullableString(
          data['post_history_instructions'],
        ),
        alternateGreetings: _stringList(data['alternate_greetings']),
        exampleMessages: _nullableString(data['mes_example']),
        extensions: data['extensions'] is Map
            ? Map<String, dynamic>.from(data['extensions'] as Map)
            : const <String, dynamic>{},
        sourceFormat: CharacterImportFormat.jsonV2,
        sourceSite: sourceSite,
        sourceUrl: sourceUrl,
        importedAt: now,
        createdAt: now,
        updatedAt: now,
        rawCardJson: rawJson,
      ),
      warnings: warnings,
    );
  }

  List<String> _buildWarnings(Map<String, dynamic> data) {
    final warnings = <String>[];
    if (_stringValue(data['name']).isEmpty) {
      warnings.add('missing_name');
    }
    if (_stringValue(data['description']).isEmpty) {
      warnings.add('missing_description');
    }
    if (_stringValue(data['first_mes']).isEmpty) {
      warnings.add('missing_first_message');
    }
    return warnings;
  }

  String _stringValue(Object? value) {
    return value is String ? value.trim() : '';
  }

  String? _nullableString(Object? value) {
    final normalized = _stringValue(value);
    return normalized.isEmpty ? null : normalized;
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return [
      for (final item in value)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }

  String _avatarFallback(String name) {
    if (name.trim().isEmpty) {
      return 'C';
    }
    return String.fromCharCode(name.runes.first).toUpperCase();
  }
}
