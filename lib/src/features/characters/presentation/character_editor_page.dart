import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/character.dart';
import '../../../shared/presentation/widgets/ot_character_avatar.dart';

class CharacterEditorPage extends StatefulWidget {
  const CharacterEditorPage({this.existing, super.key});

  final Character? existing;

  @override
  State<CharacterEditorPage> createState() => _CharacterEditorPageState();
}

class _CharacterEditorPageState extends State<CharacterEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _personalityController;
  late final TextEditingController _scenarioController;
  late final TextEditingController _firstMessageController;
  late final TextEditingController _tagsController;
  late final TextEditingController _creatorController;
  bool _isFavorite = false;
  String? _avatarImagePath;
  String? _avatarImageBase64;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _personalityController = TextEditingController(
      text: existing?.personality ?? '',
    );
    _scenarioController = TextEditingController(text: existing?.scenario ?? '');
    _firstMessageController = TextEditingController(
      text: existing?.firstMessage ?? '',
    );
    _tagsController = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );
    _creatorController = TextEditingController(text: existing?.creator ?? '');
    _isFavorite = existing?.isFavorite ?? false;
    _avatarImagePath = existing?.avatarImagePath;
    _avatarImageBase64 = existing?.avatarImageBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _personalityController.dispose();
    _scenarioController.dispose();
    _firstMessageController.dispose();
    _tagsController.dispose();
    _creatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(_isEditing ? context.l10n.editCharacter : context.l10n.createCharacter),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const StadiumBorder(),
              ),
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        children: [
          _SectionTitle(context.l10n.basicInfo),
          _AvatarPanel(
            character: _draftCharacter,
            onPickImage: _pickAvatarImage,
            onClearImage: _clearAvatarImage,
          ),
          const SizedBox(height: 12),
          _FormGroup(
            children: [
              _FormFieldRow(
                label: context.l10n.name,
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              _FormFieldRow(
                label: context.l10n.creator,
                controller: _creatorController,
                textInputAction: TextInputAction.next,
              ),
              _FormFieldRow(
                label: context.l10n.tags,
                controller: _tagsController,
                hintText: context.l10n.tagsHint,
                textInputAction: TextInputAction.next,
              ),
              _SwitchRow(
                label: context.l10n.favorite,
                value: _isFavorite,
                onChanged: (value) => setState(() => _isFavorite = value),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(context.l10n.characterSettings),
          _FormGroup(
            children: [
              _FormFieldRow(
                label: context.l10n.description,
                controller: _descriptionController,
                maxLines: 4,
              ),
              _FormFieldRow(
                label: context.l10n.personality,
                controller: _personalityController,
                maxLines: 4,
              ),
              _FormFieldRow(
                label: context.l10n.scenario,
                controller: _scenarioController,
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(context.l10n.dialogue),
          _FormGroup(
            children: [
              _FormFieldRow(
                label: context.l10n.firstMessage,
                controller: _firstMessageController,
                maxLines: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final existing = widget.existing;
    final now = DateTime.now();
    Navigator.of(context).pop(
      Character(
        id: existing?.id ?? 'char-${now.microsecondsSinceEpoch}',
        name: name,
        description: _descriptionController.text.trim(),
        personality: _personalityController.text.trim(),
        scenario: _scenarioController.text.trim(),
        firstMessage: _firstMessageController.text.trim(),
        avatar: String.fromCharCode(name.runes.first).toUpperCase(),
        avatarImagePath: _avatarImagePath,
        avatarImageBase64: _avatarImageBase64,
        tags: [
          for (final item in _tagsController.text.split(','))
            if (item.trim().isNotEmpty) item.trim(),
        ],
        creator: _creatorController.text.trim().isEmpty
            ? null
            : _creatorController.text.trim(),
        isFavorite: _isFavorite,
        sourceFormat: existing?.sourceFormat ?? CharacterImportFormat.manual,
        sourceSite: existing?.sourceSite,
        sourceUrl: existing?.sourceUrl,
        importedAt: existing?.importedAt,
        rawCardJson: existing?.rawCardJson,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        lastUsedAt: existing?.lastUsedAt,
      ),
    );
  }

  Character get _draftCharacter {
    final existing = widget.existing;
    final name = _nameController.text.trim();
    return Character(
      id: existing?.id ?? 'draft',
      name: name.isEmpty ? (existing?.name ?? 'Character') : name,
      description: _descriptionController.text.trim(),
      personality: _personalityController.text.trim(),
      scenario: _scenarioController.text.trim(),
      firstMessage: _firstMessageController.text.trim(),
      avatar: name.isEmpty
          ? (existing?.avatar ?? 'C')
          : String.fromCharCode(name.runes.first).toUpperCase(),
      avatarImagePath: _avatarImagePath,
      avatarImageBase64: _avatarImageBase64,
      tags: const <String>[],
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _pickAvatarImage() async {
    const typeGroup = XTypeGroup(
      label: 'Avatar Image',
      extensions: <String>['png', 'jpg', 'jpeg', 'webp'],
      mimeTypes: <String>['image/png', 'image/jpeg', 'image/webp'],
    );
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[typeGroup],
    );
    if (file == null) {
      return;
    }

    final bytes = await File(file.path).readAsBytes();
    setState(() {
      _avatarImageBase64 = base64Encode(bytes);
    });
  }

  void _clearAvatarImage() {
    setState(() {
      _avatarImagePath = null;
      _avatarImageBase64 = null;
    });
  }
}

class _AvatarPanel extends StatelessWidget {
  const _AvatarPanel({
    required this.character,
    required this.onPickImage,
    required this.onClearImage,
  });

  final Character character;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final hasImage =
        (character.avatarImagePath?.isNotEmpty ?? false) ||
        (character.avatarImageBase64?.isNotEmpty ?? false);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border),
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            OTCharacterAvatar(character: character, radius: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.avatar,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage ? context.l10n.avatarSet : context.l10n.avatarNotSet,
                    style: TextStyle(color: colors.secondaryText, fontSize: 13),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onPickImage, child: Text(context.l10n.pickImage)),
            if (hasImage)
              TextButton(
                onPressed: onClearImage,
                style: TextButton.styleFrom(foregroundColor: colors.danger),
                child: Text(context.l10n.clear),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: context.otColors.primaryText,
        ),
      ),
    );
  }
}

class _FormGroup extends StatelessWidget {
  const _FormGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.otColors.surface,
        border: Border(
          top: BorderSide(color: context.otColors.border),
          bottom: BorderSide(color: context.otColors.border),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _FormFieldRow extends StatelessWidget {
  const _FormFieldRow({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hintText,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hintText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.otColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: maxLines,
            maxLines: maxLines,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: isMultiline ? 15 : 16,
              height: isMultiline ? 1.45 : 1.3,
              color: context.otColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.otColors.primaryText,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (nextValue) {
              HapticFeedback.selectionClick();
              onChanged(nextValue);
            },
          ),
        ],
      ),
    );
  }
}
