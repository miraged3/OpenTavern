import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/character.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/utils/markdown_text.dart';
import '../../../shared/presentation/widgets/ot_character_avatar.dart';
import '../../../shared/presentation/widgets/ot_choice_sheet.dart';
import '../../../shared/presentation/widgets/ot_search_field.dart';

enum _CharacterFilter { all, favorites }

class CharactersPage extends ConsumerStatefulWidget {
  const CharactersPage({super.key});

  @override
  ConsumerState<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends ConsumerState<CharactersPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  _CharacterFilter _filter = _CharacterFilter.all;
  bool _selectionMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final characters = ref.watch(charactersProvider);
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        [
          for (final character in characters)
            if ((_filter == _CharacterFilter.all || character.isFavorite) &&
                (query.isEmpty ||
                    character.name.toLowerCase().contains(query) ||
                    character.description.toLowerCase().contains(query) ||
                    character.scenario.toLowerCase().contains(query) ||
                    character.tags.any(
                      (tag) => tag.toLowerCase().contains(query),
                    )))
              character,
        ]..sort((a, b) {
          final aTime =
              a.lastUsedAt ?? a.updatedAt ?? a.createdAt ?? DateTime(1970);
          final bTime =
              b.lastUsedAt ?? b.updatedAt ?? b.createdAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
    final selectedCount = _selectedIds.length;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(context.l10n.charactersTitle),
            trailing: _selectionMode
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: _exitSelectionMode,
                    child: Text(
                      context.l10n.done,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: OTSearchField(
                  placeholder: context.l10n.searchCharacters,
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            bottomMode: NavigationBarBottomMode.always,
            border: Border(bottom: BorderSide(color: colors.border)),
            backgroundColor: colors.shadowScrim,
          ),
          SliverToBoxAdapter(
            child: Container(
              color: colors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _selectionMode
                  ? Text(
                      context.l10n.selectedCharactersCount(selectedCount),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryText,
                      ),
                    )
                  : Row(
                      children: [
                        _FilterPill(
                          label: context.l10n.all,
                          selected: _filter == _CharacterFilter.all,
                          onPressed: () =>
                              setState(() => _filter = _CharacterFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: context.l10n.favorites,
                          selected: _filter == _CharacterFilter.favorites,
                          onPressed: () => setState(
                            () => _filter = _CharacterFilter.favorites,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: _openImport,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            side: BorderSide(color: colors.strongBorder),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(context.l10n.import),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _openCreate,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(context.l10n.create),
                        ),
                      ],
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider(height: 1)),
          if (_selectionMode)
            SliverToBoxAdapter(
              child: _CharacterBatchBar(
                selectedCount: selectedCount,
                onSelectAll: filtered.isEmpty
                    ? null
                    : () => _selectAll(filtered),
                onFavorite: selectedCount == 0
                    ? null
                    : () => _setSelectedFavorite(true),
                onUnfavorite: selectedCount == 0
                    ? null
                    : () => _setSelectedFavorite(false),
                onDelete: selectedCount == 0 ? null : _deleteSelected,
              ),
            ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverList.separated(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final character = filtered[index];
                return _CharacterRow(
                  character: character,
                  selected: _selectedIds.contains(character.id),
                  selectionMode: _selectionMode,
                  onOpen: () => _handleRowTap(character),
                  onLongPress: () => _handleRowLongPress(character.id),
                  onOpenMenu: () => _openCharacterActions(character),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 76),
            ),
        ],
      ),
    );
  }

  Future<void> _openImport() async {
    await context.pushNamed('character_import');
  }

  Future<void> _openCreate() async {
    final created = await context.pushNamed<Character>('character_create');
    if (created != null) {
      await ref.read(charactersProvider.notifier).upsert(created);
    }
  }

  Future<void> _openDetail(Character character) async {
    await context.pushNamed(
      'character_detail',
      pathParameters: {'characterId': character.id},
    );
  }

  void _handleRowTap(Character character) {
    if (_selectionMode) {
      _toggleSelected(character.id);
      return;
    }
    _openDetail(character);
  }

  void _handleRowLongPress(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelected(String id) {
    if (!_selectionMode) {
      return;
    }
    setState(() {
      if (!_selectedIds.add(id)) {
        _selectedIds.remove(id);
      }
      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _selectAll(List<Character> characters) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(characters.map((character) => character.id));
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _handleMenuAction(Character character, String value) async {
    switch (value) {
      case 'chat':
        await ref.read(charactersProvider.notifier).markUsed(character.id);
        final conversation = await ref
            .read(conversationsProvider.notifier)
            .createForCharacter(character);
        if (!mounted) {
          return;
        }
        context.pushNamed(
          'chat_detail',
          pathParameters: {'conversationId': conversation.id},
        );
        break;
      case 'edit':
        final edited = await context.pushNamed<Character>(
          'character_edit',
          pathParameters: {'characterId': character.id},
        );
        if (edited != null) {
          await ref.read(charactersProvider.notifier).upsert(edited);
        }
        break;
      case 'favorite':
        await ref
            .read(charactersProvider.notifier)
            .toggleFavorite(character.id);
        break;
      case 'delete':
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
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(charactersProvider.notifier).delete(character.id);
        }
        break;
    }
  }

  Future<void> _openCharacterActions(Character character) async {
    final options = <_CharacterActionOption>[
      _CharacterActionOption.chat,
      _CharacterActionOption.edit,
      _CharacterActionOption.favorite,
      _CharacterActionOption.delete,
    ];
    final l10n = context.l10n;
    final value = await showOtChoiceSheet<_CharacterActionOption>(
      context: context,
      title: l10n.characterActions,
      values: options,
      labelBuilder: (value) => switch (value) {
        _CharacterActionOption.chat => l10n.startChat,
        _CharacterActionOption.edit => l10n.edit,
        _CharacterActionOption.favorite => character.isFavorite ? l10n.unfavorite : l10n.favorite,
        _CharacterActionOption.delete => l10n.delete,
      },
    );
    if (value != null) {
      await _handleMenuAction(character, value.actionValue);
    }
  }

  Future<void> _setSelectedFavorite(bool isFavorite) async {
    await ref
        .read(charactersProvider.notifier)
        .setSelectedFavorite(_selectedIds, isFavorite);
  }

  Future<void> _deleteSelected() async {
    await ref.read(charactersProvider.notifier).deleteMany(_selectedIds);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }
}

class _CharacterRow extends StatelessWidget {
  const _CharacterRow({
    required this.character,
    required this.selected,
    required this.selectionMode,
    required this.onOpen,
    required this.onLongPress,
    required this.onOpenMenu,
  });

  final Character character;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final summary = character.description.isNotEmpty
        ? markdownToPreviewText(character.description)
        : markdownToPreviewText(character.scenario);
    final secondary = [
      if (character.creator?.trim().isNotEmpty == true)
        character.creator!.trim(),
      if (character.tags.isNotEmpty) character.tags.take(2).join(' · '),
    ].where((item) => item.isNotEmpty).join('  ·  ');

    return Material(
      color: context.otColors.surface,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpen,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    if (selectionMode) ...[
                      _SelectionIndicator(selected: selected),
                      const SizedBox(width: 12),
                    ],
                    OTCharacterAvatar(character: character, radius: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  character.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.otColors.primaryText,
                                  ),
                                ),
                              ),
                              if (character.isFavorite)
                                Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: context.otColors.warning,
                                  ),
                                ),
                            ],
                          ),
                          if (secondary.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              secondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.otColors.secondaryText,
                              ),
                            ),
                          ],
                          if (summary.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: context.otColors.primaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IgnorePointer(
              ignoring: selectionMode,
              child: Opacity(
                opacity: selectionMode ? 0.0 : 1.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onOpenMenu,
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: context.otColors.tertiaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected
            ? context.otColors.primaryText
            : context.otColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? context.otColors.primaryText
              : context.otColors.strongBorder,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check_rounded,
              size: 14,
              color: context.otColors.inverseText,
            )
          : null,
    );
  }
}

class _CharacterBatchBar extends StatelessWidget {
  const _CharacterBatchBar({
    required this.selectedCount,
    required this.onSelectAll,
    required this.onFavorite,
    required this.onUnfavorite,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onFavorite;
  final VoidCallback? onUnfavorite;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.otColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          _BatchPillButton(label: context.l10n.selectAll, onPressed: onSelectAll),
          const SizedBox(width: 8),
          _BatchPillButton(label: context.l10n.favorite, onPressed: onFavorite),
          const SizedBox(width: 8),
          _BatchPillButton(label: context.l10n.unfavorite, onPressed: onUnfavorite),
          const Spacer(),
          _BatchPillButton(
            label: selectedCount == 0 ? context.l10n.delete : '${context.l10n.delete} $selectedCount',
            onPressed: onDelete,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _BatchPillButton extends StatelessWidget {
  const _BatchPillButton({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDestructive
        ? context.otColors.danger
        : context.otColors.primaryText;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: foregroundColor,
        backgroundColor: context.otColors.mutedFill,
        disabledForegroundColor: context.otColors.tertiaryText,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

enum _CharacterActionOption { chat, edit, favorite, delete }

extension on _CharacterActionOption {
  String get actionValue {
    return switch (this) {
      _CharacterActionOption.chat => 'chat',
      _CharacterActionOption.edit => 'edit',
      _CharacterActionOption.favorite => 'favorite',
      _CharacterActionOption.delete => 'delete',
    };
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: selected
            ? context.otColors.primaryText
            : context.otColors.mutedFill,
        foregroundColor: selected
            ? context.otColors.inverseText
            : context.otColors.primaryText,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          context.l10n.noCharacters,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.otColors.secondaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
