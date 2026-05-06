import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/llm/character_prompt_builder.dart';
import '../../../core/models/conversation.dart';
import '../../../core/models/user_persona.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/widgets/ot_character_avatar.dart';
import '../../../shared/presentation/widgets/ot_search_field.dart';

class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({super.key});

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  String _query = '';
  final Set<String> _selectedIds = <String>{};
  bool _selectionMode = false;

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final query = _query.trim().toLowerCase();

    final filteredConversations = query.isEmpty
        ? conversations
        : conversations.where((conversation) {
            if (conversation.character.name.toLowerCase().contains(query)) {
              return true;
            }
            return conversation.messages.any(
              (message) => message.content.toLowerCase().contains(query),
            );
          }).toList();

    final selectedCount = _selectedIds.length;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(
                context.l10n.chatTitle,
                style: OTStyle.textStyle(
                  color: context.otColors.primaryText,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              trailing: _selectionMode
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: _exitSelectionMode,
                      child: Text(
                        context.l10n.done,
                        style: OTStyle.textStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: OTSearchField(
                    placeholder: context.l10n.searchConversations,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              bottomMode: NavigationBarBottomMode.always,
              border: Border(
                bottom: BorderSide(color: context.otColors.border),
              ),
              backgroundColor: context.otColors.shadowScrim,
            ),
            if (_selectionMode)
              SliverToBoxAdapter(
                child: Container(
                  color: context.otColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Text(
                    context.l10n.selectedCount(selectedCount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.otColors.primaryText,
                    ),
                  ),
                ),
              ),
            if (_selectionMode)
              SliverToBoxAdapter(
                child: _ConversationBatchBar(
                  selectedCount: selectedCount,
                  onSelectAll: filteredConversations.isEmpty
                      ? null
                      : () => _selectAll(filteredConversations),
                  onDelete: selectedCount == 0 ? null : _deleteSelected,
                ),
              ),
            if (conversations.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.l10n.noConversations,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.otColors.secondaryText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            else if (filteredConversations.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.l10n.noSearchResults,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.otColors.secondaryText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemCount: filteredConversations.length,
                itemBuilder: (context, index) {
                  final conversation = filteredConversations[index];
                  return _ConversationRow(
                    conversation: conversation,
                    selectionMode: _selectionMode,
                    selected: _selectedIds.contains(conversation.id),
                    onOpen: () => _handleConversationTap(conversation),
                    onLongPress: () =>
                        _handleConversationLongPress(conversation.id),
                    onDelete: _selectionMode
                        ? null
                        : () => _deleteConversation(conversation),
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 76),
              ),
          ],
        ),
      ),
    );
  }

  void _handleConversationTap(Conversation conversation) {
    if (_selectionMode) {
      _toggleSelected(conversation.id);
      return;
    }
    context.pushNamed(
      'chat_detail',
      pathParameters: {'conversationId': conversation.id},
    );
  }

  void _handleConversationLongPress(String id) {
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

  void _selectAll(List<Conversation> conversations) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(conversations.map((conversation) => conversation.id));
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteConversation(Conversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteConversation),
        content: Text(
          context.l10n.deleteConversationConfirm(conversation.character.name),
        ),
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
    if (confirmed != true) {
      return;
    }
    await _deleteConversationIds({conversation.id});
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteConversation),
        content: Text(context.l10n.deleteConversationsConfirm(count)),
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
    if (confirmed != true) {
      return;
    }
    await _deleteConversationIds(_selectedIds);
    if (!mounted) {
      return;
    }
    _exitSelectionMode();
  }

  Future<void> _deleteConversationIds(Set<String> ids) async {
    final generationController = ref.read(
      chatGenerationControllerProvider.notifier,
    );
    for (final id in ids) {
      if (ref.read(isConversationGeneratingProvider(id))) {
        await generationController.cancelGeneration(id);
      }
    }
    await ref.read(conversationsProvider.notifier).deleteMany({...ids});
  }
}

class _ConversationRow extends ConsumerWidget {
  const _ConversationRow({
    required this.conversation,
    required this.selectionMode,
    required this.selected,
    required this.onOpen,
    required this.onLongPress,
    required this.onDelete,
  });

  final Conversation conversation;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultUserPersona = ref.watch(defaultUserPersonaProvider);
    final selectedUserPersona = conversation.userPersonaId == null
        ? null
        : ref.watch(userPersonaByIdProvider(conversation.userPersonaId!));
    final userPersona = selectedUserPersona ?? defaultUserPersona;
    final isGenerating = ref.watch(
      isConversationGeneratingProvider(conversation.id),
    );
    final lastMessage = conversation.messages.lastOrNull;
    final subtitle = lastMessage == null
        ? conversation.character.description
        : lastMessage.isPending &&
              lastMessage.reasoning.trim().isNotEmpty &&
              lastMessage.content.trim().isEmpty
        ? context.l10n.reasoning
        : _renderMessagePreview(
            lastMessage.content,
            lastMessage.isTemplate,
            userPersona,
          );

    final row = Material(
      color: context.otColors.surface,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpen,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    if (selectionMode) ...[
                      _SelectionIndicator(selected: selected),
                      const SizedBox(width: 12),
                    ],
                    OTCharacterAvatar(
                      character: conversation.character,
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.character.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.otColors.primaryText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(conversation.updatedAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: context.otColors.secondaryText,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (isGenerating) ...[
                                const _ConversationGeneratingIndicator(),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.4,
                                    color: context.otColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (selectionMode || onDelete == null) {
      return row;
    }

    return Dismissible(
      key: ValueKey('conversation-${conversation.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onDelete!.call();
        return false;
      },
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        color: context.otColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(
          Icons.delete_rounded,
          color: context.otColors.inverseText,
          size: 24,
        ),
      ),
      child: row,
    );
  }

  String _renderMessagePreview(
    String content,
    bool isTemplate,
    UserPersona userPersona,
  ) {
    if (!isTemplate) {
      return content;
    }
    return renderCharacterCardText(
      content,
      character: conversation.character,
      userPersona: userPersona,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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

class _ConversationBatchBar extends StatelessWidget {
  const _ConversationBatchBar({
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.otColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          _BatchPillButton(
            label: context.l10n.selectAll,
            onPressed: onSelectAll,
          ),
          const Spacer(),
          _BatchPillButton(
            label: selectedCount == 0
                ? context.l10n.delete
                : '${context.l10n.delete} $selectedCount',
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

class _ConversationGeneratingIndicator extends StatefulWidget {
  const _ConversationGeneratingIndicator();

  @override
  State<_ConversationGeneratingIndicator> createState() =>
      _ConversationGeneratingIndicatorState();
}

class _ConversationGeneratingIndicatorState
    extends State<_ConversationGeneratingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dotOpacity = 0.35 + (_controller.value * 0.65);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: dotOpacity,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.replying,
              style: TextStyle(
                color: colors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
