import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/character.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/widgets/ot_character_avatar.dart';
import '../../../shared/presentation/widgets/ot_markdown_body.dart';
import '../../../shared/presentation/widgets/ot_choice_sheet.dart';

class CharacterDetailPage extends ConsumerWidget {
  const CharacterDetailPage({required this.characterId, super.key});

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref
        .watch(charactersProvider)
        .where((item) => item.id == characterId)
        .firstOrNull;

    if (character == null) {
      return Scaffold(
        backgroundColor: context.otColors.pageBackground,
        body: Center(child: Text(context.l10n.characterNotFound)),
      );
    }
    final colors = context.otColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.characterPreview),
        actions: [
          IconButton(
            tooltip: character.isFavorite ? context.l10n.unfavorite : context.l10n.favorite,
            onPressed: () => ref
                .read(charactersProvider.notifier)
                .toggleFavorite(character.id),
            icon: Icon(
              character.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: character.isFavorite
                  ? colors.warning
                  : colors.secondaryText,
            ),
          ),
          IconButton(
            tooltip: context.l10n.more,
            onPressed: () async {
              final value = await showOtChoiceSheet<_DetailActionOption>(
                context: context,
                title: context.l10n.characterActions,
                values: const [
                  _DetailActionOption.edit,
                  _DetailActionOption.delete,
                ],
                labelBuilder: (value) => switch (value) {
                  _DetailActionOption.edit => context.l10n.edit,
                  _DetailActionOption.delete => context.l10n.delete,
                },
              );
              if (!context.mounted || value == null) {
                return;
              }
              switch (value) {
                case _DetailActionOption.edit:
                  final edited = await context.pushNamed<Character>(
                    'character_edit',
                    pathParameters: {'characterId': character.id},
                  );
                  if (edited != null) {
                    await ref.read(charactersProvider.notifier).upsert(edited);
                  }
                  break;
                case _DetailActionOption.delete:
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.l10n.deleteCharacter),
                      content: Text(context.l10n.deleteCharacterConfirm(character.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(context.l10n.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: Text(context.l10n.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(charactersProvider.notifier)
                        .delete(character.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                  break;
              }
            },
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final edited = await context.pushNamed<Character>(
                      'character_edit',
                      pathParameters: {'characterId': character.id},
                    );
                    if (edited != null) {
                      await ref
                          .read(charactersProvider.notifier)
                          .upsert(edited);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: colors.strongBorder),
                  ),
                  child: Text(context.l10n.editCharacterButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(charactersProvider.notifier)
                        .markUsed(character.id);
                    final conversation = await ref
                        .read(conversationsProvider.notifier)
                        .createForCharacter(character);
                    if (context.mounted) {
                      context.pushNamed(
                        'chat_detail',
                        pathParameters: {'conversationId': conversation.id},
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(context.l10n.startChat),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CharacterHeroCard(character: character),
          ),
          const SizedBox(height: 20),
          _DetailSection(
            title: context.l10n.characterSettings,
            description: context.l10n.characterSettingsDesc,
            child: _InfoGroup(
              children: [
                _InfoRow(title: context.l10n.description, value: character.description),
                _InfoRow(title: context.l10n.personality, value: character.personality),
                _InfoRow(title: context.l10n.scenario, value: character.scenario),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _DetailSection(
            title: context.l10n.dialogueMaterials,
            description: context.l10n.dialogueMaterialsDesc,
            child: _InfoGroup(
              children: [
                _InfoRow(title: context.l10n.firstMessage, value: character.firstMessage),
                if (character.alternateGreetings.isNotEmpty)
                  _InfoRow(
                    title: context.l10n.alternateGreetings,
                    value: character.alternateGreetings.join('\n\n'),
                  ),
              ],
            ),
          ),
          if (character.creatorNotes?.trim().isNotEmpty == true ||
              character.systemPrompt?.trim().isNotEmpty == true ||
              character.postHistoryInstructions?.trim().isNotEmpty == true ||
              character.exampleMessages?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 20),
            _DetailSection(
              title: context.l10n.extendedInfo,
              description: context.l10n.extendedInfoDesc,
              child: _InfoGroup(
                children: [
                  _InfoRow(title: context.l10n.creatorNotes, value: character.creatorNotes ?? ''),
                  _InfoRow(title: context.l10n.systemPrompt, value: character.systemPrompt ?? ''),
                  _InfoRow(
                    title: context.l10n.postHistoryInstructions,
                    value: character.postHistoryInstructions ?? '',
                  ),
                  _InfoRow(
                    title: context.l10n.exampleMessages,
                    value: character.exampleMessages ?? '',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CharacterHeroCard extends StatelessWidget {
  const _CharacterHeroCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final meta = [
      if (character.creator?.trim().isNotEmpty == true)
        character.creator!.trim(),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            Color.alphaBlend(
              colors.accent.withValues(alpha: 0.06),
              colors.surface,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowScrim.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              top: -32,
              right: -18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.accent.withValues(alpha: 0.10),
                ),
                child: const SizedBox(width: 120, height: 120),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.warning.withValues(alpha: 0.08),
                ),
                child: const SizedBox(width: 112, height: 112),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OTCharacterAvatar(character: character, radius: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.primaryText,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                            ),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final item in meta)
                                    _MetaBadge(label: item),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (character.tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in character.tags.take(8))
                          _TagPill(label: tag),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final visibleChildren = children
        .where((child) => child is! SizedBox)
        .toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.otColors.surface,
        border: Border.all(color: context.otColors.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: context.otColors.shadowScrim.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < visibleChildren.length; index++) ...[
            visibleChildren[index],
            if (index != visibleChildren.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: context.otColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.otColors.mutedFill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.otColors.secondaryText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OTMarkdownBody(data: value),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.accent.withValues(alpha: 0.08),
          colors.surface,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.primaryText,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.otColors.mutedFill,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.otColors.primaryText,
        ),
      ),
    );
  }
}

enum _DetailActionOption { edit, delete }
