import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/import/character_card_importer.dart';
import '../../../core/models/character.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/widgets/ot_character_avatar.dart';
import '../../../shared/presentation/widgets/ot_markdown_body.dart';

class CharacterImportPage extends ConsumerStatefulWidget {
  const CharacterImportPage({super.key});

  @override
  ConsumerState<CharacterImportPage> createState() =>
      _CharacterImportPageState();
}

class _CharacterImportPageState extends ConsumerState<CharacterImportPage> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  CharacterImportResult? _preview;
  String? _error;
  bool _isImporting = false;

  @override
  void dispose() {
    _jsonController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final colors = context.otColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.importCharacterCard),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        children: [
          _Section(
            title: context.l10n.importMethod,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isImporting ? null : _pickJsonFile,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(context.l10n.selectFile),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isImporting ? null : _parsePastedJson,
                        icon: const Icon(Icons.preview_rounded),
                        label: Text(context.l10n.parseJson),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _urlController,
                  enabled: !_isImporting,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _isImporting ? null : _importFromUrl(),
                  decoration: InputDecoration(
                    hintText: context.l10n.pasteUrlHint,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: context.l10n.fetchFromUrl,
                      onPressed: _isImporting ? null : _importFromUrl,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: context.l10n.jsonContent,
            child: TextField(
              controller: _jsonController,
              minLines: 10,
              maxLines: 18,
              decoration: InputDecoration(
                hintText: context.l10n.jsonContentHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: TextStyle(color: colors.danger, fontSize: 13),
              ),
            ),
          ],
          if (preview != null) ...[
            const SizedBox(height: 20),
            _CharacterImportPreview(result: preview),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _savePreview,
                      child: Text(context.l10n.importOnly),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _importAndStartChat,
                      child: Text(context.l10n.importAndChat),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickJsonFile() async {
    final l10n = context.l10n;
    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      const typeGroup = XTypeGroup(
        label: 'Character Card',
        extensions: <String>['json', 'png'],
        mimeTypes: <String>['application/json', 'text/plain', 'image/png'],
      );
      final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      if (file == null) {
        return;
      }

      final extension = file.name.split('.').last.toLowerCase();
      if (extension == 'png') {
        final bytes = await File(file.path).readAsBytes();
        _parsePng(bytes, sourceSite: l10n.localFile);
      } else {
        final rawJson = await File(file.path).readAsString();
        _jsonController.text = rawJson;
        _parseJson(rawJson, sourceSite: l10n.localFile);
      }
    } catch (error) {
      setState(() {
        _error = l10n.readFileFailed(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _parsePastedJson() {
    _parseJson(_jsonController.text.trim());
  }

  Future<void> _importFromUrl() async {
    final l10n = context.l10n;
    final rawUrl = _urlController.text.trim();
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      setState(() {
        _error = l10n.invalidUrl;
        _preview = null;
      });
      return;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      setState(() {
        _error = l10n.onlyHttpHttps;
        _preview = null;
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      final response = await Dio().get<List<int>>(
        uri.toString(),
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const <int>[]);
      if (bytes.isEmpty) {
        throw FormatException(l10n.downloadEmpty);
      }

      if (_looksLikePng(bytes, response, uri)) {
        _parsePng(bytes, sourceUrl: uri.toString(), sourceSite: uri.host);
      } else {
        final rawJson = utf8.decode(bytes);
        _jsonController.text = rawJson;
        _parseJson(rawJson, sourceUrl: uri.toString(), sourceSite: uri.host);
      }
    } on DioException catch (error) {
      setState(() {
        _error = context.l10n.downloadFailed(_describeDownloadError(error));
        _preview = null;
      });
    } catch (error) {
      setState(() {
        _error = context.l10n.urlImportFailed(error.toString());
        _preview = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  bool _looksLikePng(Uint8List bytes, Response<List<int>> response, Uri uri) {
    final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
    return (bytes.length >= 8 &&
            bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4E &&
            bytes[3] == 0x47) ||
        contentType.toLowerCase().contains('image/png') ||
        uri.path.toLowerCase().endsWith('.png');
  }

  String _describeDownloadError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return context.l10n.serverReturnedStatus(statusCode);
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return context.l10n.connectionTimeout;
    }
    return error.message ?? error.toString();
  }

  void _parseJson(String rawJson, {String? sourceUrl, String? sourceSite}) {
    if (rawJson.isEmpty) {
      setState(() {
        _error = context.l10n.provideJsonFirst;
        _preview = null;
      });
      return;
    }

    try {
      final result = ref
          .read(characterCardImporterProvider)
          .importJson(rawJson, sourceUrl: sourceUrl, sourceSite: sourceSite);
      setState(() {
        _preview = result;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _error = context.l10n.parseFailed(error.toString());
        _preview = null;
      });
    }
  }

  void _parsePng(Uint8List bytes, {String? sourceUrl, String? sourceSite}) {
    try {
      final result = ref
          .read(characterCardImporterProvider)
          .importPng(bytes, sourceUrl: sourceUrl, sourceSite: sourceSite);
      setState(() {
        _preview = result;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _error = context.l10n.pngParseFailed(error.toString());
        _preview = null;
      });
    }
  }

  Future<void> _savePreview() async {
    final preview = _preview;
    if (preview == null) {
      return;
    }

    await ref.read(charactersProvider.notifier).upsert(preview.character);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _importAndStartChat() async {
    final preview = _preview;
    if (preview == null) {
      return;
    }

    await ref.read(charactersProvider.notifier).upsert(preview.character);
    final conversation = await ref
        .read(conversationsProvider.notifier)
        .createForCharacter(preview.character);
    if (!mounted) {
      return;
    }
    context.pushNamed(
      'chat_detail',
      pathParameters: {'conversationId': conversation.id},
    );
  }
}

class _CharacterImportPreview extends StatelessWidget {
  const _CharacterImportPreview({required this.result});

  final CharacterImportResult result;

  @override
  Widget build(BuildContext context) {
    final character = result.character;

    return _Section(
      title: context.l10n.importReview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OTCharacterAvatar(character: character, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(
                        color: context.otColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLabel(context, character.sourceFormat),
                      style: TextStyle(
                        color: context.otColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PreviewRow(label: context.l10n.name, value: character.name),
          _PreviewRow(label: context.l10n.formatLabel, value: _formatLabel(context, character.sourceFormat)),
          _PreviewRow(
            label: context.l10n.authorLabel,
            value: character.creator?.trim().isNotEmpty == true
                ? character.creator!
                : context.l10n.notProvided,
          ),
          _PreviewRow(
            label: context.l10n.tags,
            value: character.tags.isEmpty ? context.l10n.none : character.tags.join(', '),
          ),
          _PreviewRow(
            label: context.l10n.firstMessage,
            value: character.firstMessage.isEmpty
                ? context.l10n.notProvided
                : character.firstMessage,
            maxLines: 3,
            renderMarkdown: true,
          ),
          _PreviewRow(
            label: context.l10n.description,
            value: character.description.isEmpty
                ? context.l10n.notProvided
                : character.description,
            maxLines: 4,
            renderMarkdown: true,
          ),
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(context.l10n.importReminder, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            for (final warning in result.warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${_localizeWarning(context, warning)}',
                  style: TextStyle(
                    color: context.otColors.warning,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _localizeWarning(BuildContext context, String warning) {
    return switch (warning) {
      'missing_name' => context.l10n.missingNameWarning,
      'missing_description' => context.l10n.missingDescriptionWarning,
      'missing_first_message' => context.l10n.missingFirstMessageWarning,
      _ => warning,
    };
  }

  String _formatLabel(BuildContext context, CharacterImportFormat format) {
    return switch (format) {
      CharacterImportFormat.manual => context.l10n.importFormatManual,
      CharacterImportFormat.jsonV1 => 'JSON V1',
      CharacterImportFormat.jsonV2 => 'JSON V2',
      CharacterImportFormat.pngV1 => 'PNG V1',
      CharacterImportFormat.pngV2 => 'PNG V2',
      CharacterImportFormat.siteImport => context.l10n.importFormatSiteImport,
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.otColors.primaryText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.renderMarkdown = false,
  });

  final String label;
  final String value;
  final int maxLines;
  final bool renderMarkdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.otColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          if (renderMarkdown && maxLines > 1)
            OTMarkdownBody(data: value, compact: true)
          else
            Text(
              value,
              maxLines: maxLines,
              overflow: maxLines == 1
                  ? TextOverflow.ellipsis
                  : TextOverflow.fade,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
        ],
      ),
    );
  }
}
