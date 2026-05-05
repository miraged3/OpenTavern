import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/app_log_entry.dart';
import '../../../core/providers/app_providers.dart';

class AppLogsPage extends ConsumerWidget {
  const AppLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.otColors;
    final logs = ref.watch(appLogsProvider);
    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        title: Text(context.l10n.runtimeLogs),
        actions: [
          IconButton(
            onPressed: logs.isEmpty ? null : () => _exportLogs(context, ref),
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: context.l10n.export,
          ),
          IconButton(
            onPressed: logs.isEmpty ? null : () => _clearLogs(context, ref),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: context.l10n.clearLogs,
          ),
        ],
      ),
      body: logs.isEmpty
          ? Center(
              child: Text(
                context.l10n.noLogsYet,
                style: TextStyle(color: colors.secondaryText, fontSize: 15),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: logs.length,
              reverse: true,
              itemBuilder: (context, index) {
                final entry = logs[logs.length - 1 - index];
                return _LogEntryCard(entry: entry);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
    );
  }

  Future<void> _clearLogs(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    await ref.read(appLogsProvider.notifier).clear();
  }

  Future<void> _exportLogs(BuildContext context, WidgetRef ref) async {
    final saveLocation = await getSaveLocation(
      suggestedName:
          'open_tavern_logs_${DateTime.now().toIso8601String().replaceAll(':', '-')}.txt',
    );
    if (saveLocation == null) {
      return;
    }
    final logs = ref.read(appLogsProvider);
    final content = logs.map(_formatEntry).join('\n\n');
    await File(saveLocation.path).writeAsString(content);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.logsExported)));
  }

  String _formatEntry(AppLogEntry entry) {
    final buffer = StringBuffer()
      ..writeln(
        '[${entry.timestamp.toIso8601String()}] ${entry.level.name.toUpperCase()} ${entry.scope}',
      )
      ..writeln(entry.message);
    if (entry.details != null && entry.details!.trim().isNotEmpty) {
      buffer.writeln(entry.details);
    }
    return buffer.toString().trimRight();
  }
}

class _LogEntryCard extends StatelessWidget {
  const _LogEntryCard({required this.entry});

  final AppLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return DecoratedBox(
      decoration: OTStyle.flatGroupDecoration(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _levelColor(colors, entry.level),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.level.name.toUpperCase(),
                  style: TextStyle(
                    color: _levelColor(colors, entry.level),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.scope,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatTime(entry.timestamp),
                  style: TextStyle(color: colors.tertiaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.message,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (entry.details != null && entry.details!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              SelectableText(
                entry.details!,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _levelColor(OTThemeColors colors, AppLogLevel level) {
    return switch (level) {
      AppLogLevel.info => colors.accent,
      AppLogLevel.warning => colors.warning,
      AppLogLevel.error => colors.danger,
    };
  }

  String _formatTime(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute:$second';
  }
}
