import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/llm/character_prompt_builder.dart';
import '../../../core/models/character.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/conversation.dart';
import '../../../core/models/generation_config.dart';
import '../../../core/models/model_endpoint.dart';
import '../../../core/models/user_persona.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/widgets/ot_character_avatar.dart';
import '../../../shared/presentation/widgets/ot_choice_sheet.dart';
import '../../../shared/presentation/widgets/generation_config_sheet.dart';
import '../../../shared/presentation/widgets/ot_markdown_body.dart';
import '../../../shared/presentation/widgets/ot_user_avatar.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  const ChatDetailPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const double _attachmentMenuHeight = 224;
  static const double _composerControlHeight = 40;
  static const double _composerMaxHeight = 120;
  static const _menuExpandCurve = Cubic(0.22, 1.0, 0.36, 1.0);
  static const _menuCollapseCurve = Cubic(0.32, 0.0, 0.67, 0.0);
  static const _menuItemsCurve = Cubic(0.2, 0.82, 0.2, 1.0);
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _messagesScrollController = ScrollController();
  late final AnimationController _menuController;
  double _keyboardHeight = 0;
  bool _isMenuOpen = false;
  bool _isPlusPressed = false;
  bool _isMenuInteracting = false;
  int _lastMessageCount = 0;
  bool _hasAlignedInitialScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus && _isMenuOpen) {
        _toggleAttachmentMenu(false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateKeyboardHeight();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _menuController.dispose();
    _messagesScrollController.dispose();
    _inputFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateKeyboardHeight();
  }

  void _updateKeyboardHeight() {
    if (!mounted) return;
    final view = View.of(context);
    final newHeight = MediaQueryData.fromView(view).viewInsets.bottom;
    if (_keyboardHeight != newHeight) {
      final shouldStickToBottom = _isNearBottom();
      setState(() => _keyboardHeight = newHeight);
      if (shouldStickToBottom) {
        _scheduleScrollToBottom(animated: false);
      }
    }
  }

  void _toggleAttachmentMenu([bool? open]) {
    final nextOpen = open ?? !_isMenuOpen;
    if (nextOpen == _isMenuOpen) {
      return;
    }
    setState(() {
      _isMenuOpen = nextOpen;
      _isMenuInteracting = false;
    });
    if (nextOpen) {
      _menuController.forward();
      HapticFeedback.selectionClick();
    } else {
      _menuController.reverse();
    }
  }

  void _handleMenuDragStart(DragStartDetails details) {
    _inputFocusNode.unfocus();
    if (!_isMenuInteracting) {
      setState(() => _isMenuInteracting = true);
    }
  }

  void _handleMenuDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) {
      return;
    }
    _menuController.value =
        (_menuController.value - (delta / _attachmentMenuHeight)).clamp(
          0.0,
          1.0,
        );
  }

  void _handleMenuDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen =
        velocity < -240 || (velocity <= 240 && _menuController.value > 0.45);
    setState(() => _isMenuInteracting = false);
    if (shouldOpen) {
      final wasClosed = !_isMenuOpen;
      setState(() => _isMenuOpen = true);
      _menuController.forward();
      if (wasClosed) {
        HapticFeedback.selectionClick();
      }
    } else {
      setState(() => _isMenuOpen = false);
      _menuController.reverse();
    }
  }

  void _handleMenuDragCancel() {
    if (!_isMenuInteracting) {
      return;
    }
    setState(() => _isMenuInteracting = false);
    if (_menuController.value > 0.45) {
      setState(() => _isMenuOpen = true);
      _menuController.forward();
    } else {
      setState(() => _isMenuOpen = false);
      _menuController.reverse();
    }
  }

  double _menuCurveValue({
    required Curve expandCurve,
    required Curve collapseCurve,
  }) {
    final value = _menuController.value.clamp(0.0, 1.0);
    if (_isMenuInteracting) {
      return value;
    }
    final useCollapseCurve = !_isMenuOpen;
    return (useCollapseCurve ? collapseCurve : expandCurve).transform(value);
  }

  bool _isNearBottom() {
    if (!_messagesScrollController.hasClients) {
      return true;
    }
    final position = _messagesScrollController.position;
    return position.pixels <= 72;
  }

  void _scheduleScrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) {
        return;
      }
      if (animated) {
        _messagesScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      } else {
        _messagesScrollController.jumpTo(0);
      }
    });
  }

  Future<void> _retryFailedMessage(
    Conversation conversation,
    ChatMessage failedMessage,
    UserPersona userPersona,
  ) async {
    final isGenerating = ref.read(
      isConversationGeneratingProvider(conversation.id),
    );
    if (isGenerating) {
      return;
    }
    HapticFeedback.selectionClick();
    final cleanedConversation = conversation.copyWith(
      messages: conversation.messages
          .where((message) => message.id != failedMessage.id)
          .toList(),
      updatedAt: DateTime.now(),
    );
    await ref
        .read(conversationsProvider.notifier)
        .replaceConversation(cleanedConversation);
    await ref
        .read(chatGenerationControllerProvider.notifier)
        .generateReplyForConversation(
          cleanedConversation,
          userPersona: userPersona,
        );
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(
      conversationByIdProvider(widget.conversationId),
    );

    if (conversation == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.conversationNotFound)),
      );
    }

    final character = conversation.character;
    final defaultUserPersona = ref.watch(defaultUserPersonaProvider);
    final selectedUserPersona = conversation.userPersonaId == null
        ? null
        : ref.watch(userPersonaByIdProvider(conversation.userPersonaId!));
    final userPersona = selectedUserPersona ?? defaultUserPersona;
    final enterKeyToSend = ref.watch(enterKeyToSendProvider);
    final isGenerating = ref.watch(
      isConversationGeneratingProvider(conversation.id),
    );
    final colors = context.otColors;
    final bottomSafeInset = MediaQuery.of(context).viewPadding.bottom;
    final composerBottomInset = _keyboardHeight > bottomSafeInset
        ? _keyboardHeight
        : bottomSafeInset;
    final messageCount = conversation.messages.length;
    final shouldAutoScroll =
        !_hasAlignedInitialScroll ||
        (messageCount > _lastMessageCount && _isNearBottom()) ||
        (isGenerating && _isNearBottom());
    if (shouldAutoScroll) {
      _scheduleScrollToBottom(animated: _hasAlignedInitialScroll);
      _hasAlignedInitialScroll = true;
    }
    _lastMessageCount = messageCount;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(character.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _inputFocusNode.unfocus();
                if (_isMenuOpen) {
                  _toggleAttachmentMenu(false);
                }
              },
              child: ListView.builder(
                controller: _messagesScrollController,
                reverse: true,
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
                itemCount: conversation.messages.length,
                itemBuilder: (context, index) {
                  final message = conversation
                      .messages[conversation.messages.length - 1 - index];
                  final isUser = message.role == MessageRole.user;
                  return _ChatMessageRow(
                    message: message,
                    character: character,
                    userPersona: userPersona,
                    onRetry:
                        message.role == MessageRole.system &&
                            (message.content == 'system_send_failed' ||
                                message.content == '发送失败，点击重试')
                        ? () => _retryFailedMessage(
                            conversation,
                            message,
                            userPersona,
                          )
                        : null,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                    },
                    onDelete: () => _deleteMessage(conversation, message),
                    onEdit: message.role == MessageRole.system
                        ? null
                        : (newContent) =>
                              _editMessage(conversation, message, newContent),
                    onRegenerate: !isUser
                        ? () => _regenerateFromMessage(conversation, message)
                        : null,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + composerBottomInset),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragStart: _handleMenuDragStart,
                  onVerticalDragUpdate: _handleMenuDragUpdate,
                  onVerticalDragEnd: _handleMenuDragEnd,
                  onVerticalDragCancel: _handleMenuDragCancel,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: _composerControlHeight,
                                maxHeight: _composerMaxHeight,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.mutedFill,
                                  borderRadius: BorderRadius.circular(
                                    _composerControlHeight / 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child:
                                      ValueListenableBuilder<TextEditingValue>(
                                        valueListenable: _messageController,
                                        builder: (context, value, child) {
                                          return Stack(
                                            children: [
                                              if (value.text.isEmpty)
                                                Text(
                                                  context.l10n.inputMessageHint,
                                                  style: TextStyle(
                                                    color: colors.secondaryText
                                                        .withValues(
                                                          alpha: 0.72,
                                                        ),
                                                    fontSize: 16,
                                                    height: 1.25,
                                                  ),
                                                ),
                                              EditableText(
                                                controller: _messageController,
                                                focusNode: _inputFocusNode,
                                                readOnly: isGenerating,
                                                minLines: 1,
                                                maxLines: null,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textInputAction: enterKeyToSend
                                                    ? TextInputAction.send
                                                    : TextInputAction.newline,
                                                onSubmitted:
                                                    enterKeyToSend &&
                                                        !isGenerating
                                                    ? (_) => _sendMessage(
                                                        conversation,
                                                      )
                                                    : null,
                                                onTapOutside: (_) =>
                                                    _inputFocusNode.unfocus(),
                                                style: TextStyle(
                                                  color: colors.primaryText,
                                                  fontSize: 16,
                                                  height: 1.25,
                                                ),
                                                cursorColor: colors.accent,
                                                backgroundCursorColor:
                                                    colors.tertiaryText,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isPlusPressed = true),
                            onTapUp: (_) =>
                                setState(() => _isPlusPressed = false),
                            onTapCancel: () =>
                                setState(() => _isPlusPressed = false),
                            onTap: () {
                              _inputFocusNode.unfocus();
                              _toggleAttachmentMenu();
                            },
                            child: AnimatedScale(
                              scale: _isPlusPressed ? 0.92 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOutCubic,
                              child: AnimatedBuilder(
                                animation: _menuController,
                                builder: (context, child) {
                                  final iconTurn =
                                      Tween<double>(
                                        begin: 0,
                                        end: 0.125,
                                      ).transform(
                                        _menuCurveValue(
                                          expandCurve: _menuExpandCurve,
                                          collapseCurve: _menuCollapseCurve,
                                        ),
                                      );
                                  final backgroundColor = Color.lerp(
                                    colors.mutedFill,
                                    colors.primaryText.withValues(alpha: 0.08),
                                    _menuController.value,
                                  );
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    width: _composerControlHeight,
                                    height: _composerControlHeight,
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Transform.rotate(
                                      angle: iconTurn * 3.141592653589793 * 2,
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: colors.primaryText,
                                        size: 22,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _messageController,
                            builder: (context, value, child) {
                              final hasText = value.text.trim().isNotEmpty;
                              final isEnabled = isGenerating || hasText;
                              return AnimatedOpacity(
                                opacity: isEnabled ? 1.0 : 0.4,
                                duration: const Duration(milliseconds: 150),
                                child: GestureDetector(
                                  onTap: isGenerating
                                      ? () {
                                          HapticFeedback.selectionClick();
                                          ref
                                              .read(
                                                chatGenerationControllerProvider
                                                    .notifier,
                                              )
                                              .cancelGeneration(
                                                conversation.id,
                                              );
                                        }
                                      : hasText
                                      ? () => _sendMessage(conversation)
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    width: _composerControlHeight,
                                    height: _composerControlHeight,
                                    decoration: BoxDecoration(
                                      color: isGenerating
                                          ? colors.primaryText
                                          : colors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: isGenerating
                                          ? Icon(
                                              Icons.stop_rounded,
                                              key: const ValueKey('stop'),
                                              color: colors.inverseText,
                                              size: 20,
                                            )
                                          : Icon(
                                              Icons.send_rounded,
                                              key: const ValueKey('send'),
                                              color: colors.inverseText,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ClipRect(
                        child: AnimatedBuilder(
                          animation: _menuController,
                          builder: (context, child) {
                            final heightProgress = _menuCurveValue(
                              expandCurve: _menuExpandCurve,
                              collapseCurve: _menuCollapseCurve,
                            );
                            final contentProgress = _menuCurveValue(
                              expandCurve: _menuItemsCurve,
                              collapseCurve: _menuCollapseCurve,
                            );
                            return SizedBox(
                              height: _attachmentMenuHeight * heightProgress,
                              child: OverflowBox(
                                alignment: Alignment.topCenter,
                                minHeight: 0,
                                maxHeight: _attachmentMenuHeight,
                                child: SizedBox(
                                  height: _attachmentMenuHeight,
                                  child: Opacity(
                                    opacity: contentProgress,
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        (1 - heightProgress) * 26,
                                      ),
                                      child: Transform.scale(
                                        scale: 0.94 + (contentProgress * 0.06),
                                        alignment: Alignment.bottomCenter,
                                        child: _AttachmentMenuGrid(
                                          conversation: conversation,
                                          onSelectModel: () =>
                                              _showModelSelector(conversation),
                                          onEditGenerationConfig: () =>
                                              _showGenerationConfigEditor(
                                                conversation,
                                              ),
                                          animationValue: contentProgress,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(Conversation conversation) async {
    final rawInput = _messageController.text.trim();
    final isGenerating = ref.read(
      isConversationGeneratingProvider(conversation.id),
    );
    if (rawInput.isEmpty || isGenerating) {
      return;
    }

    setState(() {
      _messageController.clear();
    });
    await ref
        .read(chatGenerationControllerProvider.notifier)
        .sendMessage(conversationId: conversation.id, rawInput: rawInput);
  }

  Future<void> _deleteMessage(
    Conversation conversation,
    ChatMessage message,
  ) async {
    final current = await _cancelGenerationAndReadConversation(conversation.id);
    final source = current ?? conversation;
    final nextMessages = source.messages
        .where((m) => m.id != message.id)
        .toList();
    final next = Conversation(
      id: source.id,
      character: source.character,
      messages: nextMessages,
      userPersonaId: source.userPersonaId,
      modelEndpointId: source.modelEndpointId,
      generationConfig: source.generationConfig,
      updatedAt: DateTime.now(),
    );
    await ref.read(conversationsProvider.notifier).replaceConversation(next);
  }

  Future<void> _editMessage(
    Conversation conversation,
    ChatMessage message,
    String newContent,
  ) async {
    final current = await _cancelGenerationAndReadConversation(conversation.id);
    final source = current ?? conversation;
    final index = source.messages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

    final editedMessage = ChatMessage(
      id: message.id,
      role: message.role,
      content: newContent,
      timestamp: DateTime.now(),
    );

    if (message.role == MessageRole.user) {
      final defaultUserPersona = ref.read(defaultUserPersonaProvider);
      final userPersona = source.userPersonaId == null
          ? defaultUserPersona
          : ref.read(userPersonaByIdProvider(source.userPersonaId!)) ??
                defaultUserPersona;

      final nextMessages = [
        ...source.messages.sublist(0, index),
        editedMessage,
      ];

      final next = Conversation(
        id: source.id,
        character: source.character,
        messages: nextMessages,
        userPersonaId: source.userPersonaId,
        modelEndpointId: source.modelEndpointId,
        generationConfig: source.generationConfig,
        updatedAt: DateTime.now(),
      );
      await ref.read(conversationsProvider.notifier).replaceConversation(next);

      await ref
          .read(chatGenerationControllerProvider.notifier)
          .generateReplyForConversation(next, userPersona: userPersona);
    } else {
      final nextMessages = [
        ...source.messages.sublist(0, index),
        editedMessage,
        ...source.messages.sublist(index + 1),
      ];

      final next = Conversation(
        id: source.id,
        character: source.character,
        messages: nextMessages,
        userPersonaId: source.userPersonaId,
        modelEndpointId: source.modelEndpointId,
        generationConfig: source.generationConfig,
        updatedAt: DateTime.now(),
      );
      await ref.read(conversationsProvider.notifier).replaceConversation(next);
    }
  }

  Future<void> _regenerateFromMessage(
    Conversation conversation,
    ChatMessage message,
  ) async {
    final current = await _cancelGenerationAndReadConversation(conversation.id);
    final source = current ?? conversation;
    final index = source.messages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

    final defaultUserPersona = ref.read(defaultUserPersonaProvider);
    final userPersona = source.userPersonaId == null
        ? defaultUserPersona
        : ref.read(userPersonaByIdProvider(source.userPersonaId!)) ??
              defaultUserPersona;

    final nextMessages = source.messages.sublist(0, index);
    final next = Conversation(
      id: source.id,
      character: source.character,
      messages: nextMessages,
      userPersonaId: source.userPersonaId,
      modelEndpointId: source.modelEndpointId,
      generationConfig: source.generationConfig,
      updatedAt: DateTime.now(),
    );
    await ref.read(conversationsProvider.notifier).replaceConversation(next);

    await ref
        .read(chatGenerationControllerProvider.notifier)
        .generateReplyForConversation(next, userPersona: userPersona);
  }

  Future<Conversation?> _cancelGenerationAndReadConversation(
    String conversationId,
  ) async {
    final isGenerating = ref.read(
      isConversationGeneratingProvider(conversationId),
    );
    if (isGenerating) {
      await ref
          .read(chatGenerationControllerProvider.notifier)
          .cancelGeneration(conversationId);
    }
    return ref.read(conversationByIdProvider(conversationId));
  }

  void _showModelSelector(Conversation conversation) {
    final models = ref.read(enabledModelEndpointsProvider);
    final selectedModelId =
        conversation.modelEndpointId ??
        ref.read(activeModelEndpointProvider)?.id;
    showOtChoiceSheet<ModelEndpoint>(
      context: context,
      title: context.l10n.selectModel,
      values: models,
      labelBuilder: (model) => model.id == selectedModelId
          ? '${model.name} · ${context.l10n.currentSelected}'
          : model.name,
    ).then((model) async {
      if (model == null) {
        return;
      }
      final updated = Conversation(
        id: conversation.id,
        character: conversation.character,
        messages: conversation.messages,
        userPersonaId: conversation.userPersonaId,
        modelEndpointId: model.id,
        generationConfig: conversation.generationConfig,
        updatedAt: DateTime.now(),
      );
      await ref
          .read(conversationsProvider.notifier)
          .replaceConversation(updated);
    });
  }

  Future<void> _showGenerationConfigEditor(Conversation conversation) async {
    final defaultConfig = ref.read(defaultGenerationConfigProvider);
    final result = await showGenerationConfigSheet(
      context: context,
      title: context.l10n.currentConversationParams,
      initialConfig: conversation.generationConfig ?? defaultConfig,
      resetLabel: context.l10n.useDefaultParams,
    );
    if (result == null) {
      return;
    }
    final updated = conversation.copyWith(
      generationConfig: result.reset ? null : result.config,
      updatedAt: DateTime.now(),
    );
    await ref.read(conversationsProvider.notifier).replaceConversation(updated);
  }
}

class _ChatMessageRow extends StatefulWidget {
  const _ChatMessageRow({
    required this.message,
    required this.character,
    required this.userPersona,
    this.onRetry,
    this.onCopy,
    this.onDelete,
    this.onEdit,
    this.onRegenerate,
  });

  final ChatMessage message;
  final Character character;
  final UserPersona userPersona;
  final VoidCallback? onRetry;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onEdit;
  final VoidCallback? onRegenerate;

  @override
  State<_ChatMessageRow> createState() => _ChatMessageRowState();
}

class _ChatMessageRowState extends State<_ChatMessageRow> {
  bool _isPressed = false;
  bool _isThinkingExpanded = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final character = widget.character;
    final userPersona = widget.userPersona;
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;
    final isRetryableSystem = isSystem && widget.onRetry != null;
    final colors = context.otColors;
    final renderedContent = message.isTemplate
        ? renderCharacterCardText(
            message.content,
            character: character,
            userPersona: userPersona,
          )
        : message.content;

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Center(
          child: GestureDetector(
            onTap: widget.onRetry,
            onLongPress: isRetryableSystem
                ? () => _showSystemMessageMenu(context)
                : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isRetryableSystem
                    ? colors.accent.withValues(alpha: 0.08)
                    : colors.systemFill,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _localizeSystemMessage(context, renderedContent),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isRetryableSystem
                      ? colors.accent
                      : colors.secondaryText,
                  fontWeight: isRetryableSystem
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final bubbleColor = isUser ? colors.primaryText : colors.surface;
    final borderColor = isUser ? colors.primaryText : colors.border;
    final textColor = isUser ? colors.inverseText : colors.primaryText;
    final hasReasoning = message.reasoning.trim().isNotEmpty;
    final isTypingIndicator =
        !isUser && message.isPending && renderedContent.trim().isEmpty;

    final Widget avatar = GestureDetector(
      onTap: () {
        if (isUser) {
          context.pushNamed('user_personas');
        } else {
          context.pushNamed(
            'character_detail',
            pathParameters: {'characterId': character.id},
          );
        }
      },
      child: isUser
          ? OTUserAvatar(userPersona: userPersona, radius: 18)
          : OTCharacterAvatar(character: character, radius: 18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[avatar, const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: hasReasoning
                      ? () => setState(
                          () => _isThinkingExpanded = !_isThinkingExpanded,
                        )
                      : null,
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isPressed = false);
                    _showMessageMenu(context);
                  },
                  child: AnimatedScale(
                    scale: _isPressed ? 0.96 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isUser ? 18 : 8),
                            bottomRight: Radius.circular(isUser ? 8 : 18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasReasoning)
                                _ReasoningPanel(
                                  reasoning: message.reasoning,
                                  expanded: _isThinkingExpanded,
                                  isPending: message.isPending,
                                  accentColor: isUser
                                      ? colors.inverseText.withValues(
                                          alpha: 0.92,
                                        )
                                      : colors.accent,
                                  textColor: isUser
                                      ? colors.inverseText.withValues(
                                          alpha: 0.86,
                                        )
                                      : colors.secondaryText,
                                  backgroundColor: isUser
                                      ? colors.inverseText.withValues(
                                          alpha: 0.08,
                                        )
                                      : colors.mutedFill,
                                ),
                              if (hasReasoning &&
                                  renderedContent.trim().isNotEmpty)
                                const SizedBox(height: 8),
                              if (isTypingIndicator)
                                _TypingIndicator(colors: colors)
                              else if (renderedContent.trim().isNotEmpty)
                                OTMarkdownBody(
                                  data: renderedContent,
                                  textColor: textColor,
                                  linkColor: textColor,
                                  codeBackgroundColor: isUser
                                      ? colors.inverseText.withValues(
                                          alpha: 0.14,
                                        )
                                      : colors.mutedFill,
                                  blockquoteBackgroundColor: isUser
                                      ? colors.inverseText.withValues(
                                          alpha: 0.08,
                                        )
                                      : colors.quoteBackground,
                                  blockquoteBorderColor: isUser
                                      ? colors.inverseText.withValues(
                                          alpha: 0.2,
                                        )
                                      : colors.border,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colors.tertiaryText),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8), avatar],
        ],
      ),
    );
  }

  void _showMessageMenu(BuildContext context) {
    showOtActionSheet(
      context: context,
      title: context.l10n.messageActions,
      items: [
        if (widget.onCopy != null)
          OtActionSheetItem(
            label: context.l10n.copy,
            onTap: () => widget.onCopy?.call(),
          ),
        if (widget.onEdit != null)
          OtActionSheetItem(
            label: context.l10n.edit,
            onTap: () => _showEditDialog(context),
          ),
        if (widget.onRegenerate != null)
          OtActionSheetItem(
            label: context.l10n.regenerate,
            onTap: () => widget.onRegenerate?.call(),
          ),
        if (widget.onDelete != null)
          OtActionSheetItem(
            label: context.l10n.delete,
            isDestructive: true,
            onTap: () => widget.onDelete?.call(),
          ),
      ],
    );
  }

  void _showSystemMessageMenu(BuildContext context) {
    showOtActionSheet(
      context: context,
      title: context.l10n.messageActions,
      items: [
        if (widget.onRetry != null)
          OtActionSheetItem(
            label: context.l10n.retry,
            onTap: () => widget.onRetry?.call(),
          ),
        if (widget.onDelete != null)
          OtActionSheetItem(
            label: context.l10n.delete,
            isDestructive: true,
            onTap: () => widget.onDelete?.call(),
          ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.message.content);
    showDialog(
      context: context,
      builder: (context) {
        final colors = context.otColors;
        final size = MediaQuery.sizeOf(context);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 28,
          ),
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 720,
              maxHeight: size.height * 0.82,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.editMessage,
                    style: OTStyle.textStyle(
                      color: colors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: OTStyle.textStyle(
                        color: colors.primaryText,
                        fontSize: 15,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.mutedFill,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primaryText,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onEdit?.call(controller.text);
                        },
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: Text(context.l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _localizeSystemMessage(BuildContext context, String content) {
    return switch (content) {
      'system_interrupted' => context.l10n.systemInterrupted,
      'system_send_failed' => context.l10n.systemSendFailed,
      '上次回复因应用退出或页面重建而中断' => context.l10n.systemInterrupted,
      '发送失败，点击重试' => context.l10n.systemSendFailed,
      _ => content,
    };
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AttachmentMenuGrid extends StatelessWidget {
  const _AttachmentMenuGrid({
    required this.conversation,
    required this.onSelectModel,
    required this.onEditGenerationConfig,
    this.animationValue = 1.0,
  });

  final Conversation conversation;
  final VoidCallback onSelectModel;
  final VoidCallback onEditGenerationConfig;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final progress = animationValue.clamp(0.0, 1.0);

    return SizedBox(
      height: 224,
      child: Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, (1 - progress) * 14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrimaryToolCard(
                  icon: Icons.smart_toy_rounded,
                  title: context.l10n.modelLabel,
                  subtitle: _modelLabel(context),
                  accentColor: colors.accent,
                  onTap: onSelectModel,
                ),
                const SizedBox(height: 10),
                _PrimaryToolCard(
                  icon: Icons.tune_rounded,
                  title: context.l10n.paramsLabel,
                  subtitle: _configLabel(
                    context,
                    conversation.generationConfig,
                  ),
                  accentColor: colors.warning,
                  onTap: onEditGenerationConfig,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _modelLabel(BuildContext context) {
    final model = conversation.modelEndpointId;
    if (model == null) {
      return context.l10n.currentModelDefault;
    }
    return context.l10n.currentModelAssigned;
  }

  String _configLabel(BuildContext context, GenerationConfig? config) {
    if (config == null) {
      return context.l10n.useDefaultParams;
    }
    return 'T ${config.temperature.toStringAsFixed(2)} · P ${config.topP.toStringAsFixed(2)} · ${config.maxTokens} · ${_reasoningModeLabel(context, config.reasoningMode)}';
  }

  String _reasoningModeLabel(BuildContext context, ReasoningMode mode) {
    return switch (mode) {
      ReasoningMode.off => context.l10n.reasoningOff,
      ReasoningMode.automatic => context.l10n.reasoningAutomatic,
      ReasoningMode.low => context.l10n.reasoningLow,
      ReasoningMode.medium => context.l10n.reasoningMedium,
      ReasoningMode.high => context.l10n.reasoningHigh,
    };
  }
}

class _PrimaryToolCard extends StatelessWidget {
  const _PrimaryToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 72,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.mutedFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.tertiaryText,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.colors});

  final OTThemeColors colors;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final phase = (_controller.value - (index * 0.16)).clamp(
                0.0,
                1.0,
              );
              final opacity = 0.28 + ((1 - (phase - 0.5).abs() * 2) * 0.72);
              final scale = 0.78 + ((1 - (phase - 0.5).abs() * 2) * 0.22);
              return Opacity(
                opacity: opacity.clamp(0.28, 1.0),
                child: Transform.scale(
                  scale: scale.clamp(0.78, 1.0),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.colors.secondaryText,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _ReasoningPanel extends StatefulWidget {
  const _ReasoningPanel({
    required this.reasoning,
    required this.expanded,
    required this.isPending,
    required this.accentColor,
    required this.textColor,
    required this.backgroundColor,
  });

  final String reasoning;
  final bool expanded;
  final bool isPending;
  final Color accentColor;
  final Color textColor;
  final Color backgroundColor;

  @override
  State<_ReasoningPanel> createState() => _ReasoningPanelState();
}

class _ReasoningPanelState extends State<_ReasoningPanel>
    with SingleTickerProviderStateMixin {
  static const _expandCurve = Cubic(0.18, 0.96, 0.32, 1.0);
  static const _collapseCurve = Cubic(0.12, 0.92, 0.24, 1.0);

  late final AnimationController _controller;
  bool _isCollapsing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 280),
      value: widget.expanded ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _ReasoningPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _isCollapsing = false;
        _controller.forward();
      } else {
        _isCollapsing = true;
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chevronTurns = Tween<double>(begin: 0.0, end: 0.5);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: widget.accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isPending ? context.l10n.thinking : context.l10n.thought,
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final rawValue = _controller.value;
                  final visualValue = _isCollapsing
                      ? 1 - _collapseCurve.transform(1 - rawValue)
                      : _expandCurve.transform(rawValue);
                  return Transform.rotate(
                    angle: chevronTurns.transform(visualValue) * math.pi,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final rawValue = _controller.value;
              final value = _isCollapsing
                  ? 1 - _collapseCurve.transform(1 - rawValue)
                  : _expandCurve.transform(rawValue);
              return ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * -10),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: OTMarkdownBody(
                data: widget.reasoning,
                textColor: widget.textColor,
                linkColor: widget.accentColor,
                codeBackgroundColor: widget.backgroundColor.withValues(
                  alpha: 0.72,
                ),
                blockquoteBackgroundColor: widget.backgroundColor.withValues(
                  alpha: 0.72,
                ),
                blockquoteBorderColor: widget.accentColor.withValues(
                  alpha: 0.22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
