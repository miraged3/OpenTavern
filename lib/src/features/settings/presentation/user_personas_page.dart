import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/user_persona.dart';
import '../../../core/providers/app_providers.dart';

class UserPersonasPage extends ConsumerWidget {
  const UserPersonasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personas = ref.watch(userPersonasProvider);
    final colors = context.otColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        title: Text(context.l10n.userPersonas),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _openEditor(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.l10n.addNew),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryText,
                foregroundColor: colors.inverseText,
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: OTStyle.pillShape,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        itemCount: personas.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final persona = personas[index];
          return _PersonaCard(persona: persona);
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    UserPersona? existing,
  }) async {
    final persona = await Navigator.of(context).push<UserPersona>(
      MaterialPageRoute<UserPersona>(
        builder: (context) => _UserPersonaEditorPage(existing: existing),
      ),
    );
    if (persona == null) {
      return;
    }
    await ref.read(userPersonasProvider.notifier).upsert(persona);
  }
}

class _PersonaCard extends ConsumerWidget {
  const _PersonaCard({required this.persona});

  final UserPersona persona;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.otColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: OTStyle.cardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        persona.name,
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (persona.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryText,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.defaultBadge,
                          style: TextStyle(
                            color: colors.inverseText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (persona.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    persona.description,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (persona.profilePrompt.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    persona.profilePrompt,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final updated = await Navigator.of(context)
                            .push<UserPersona>(
                              MaterialPageRoute<UserPersona>(
                                builder: (context) =>
                                    _UserPersonaEditorPage(existing: persona),
                              ),
                            );
                        if (updated == null) {
                          return;
                        }
                        await ref
                            .read(userPersonasProvider.notifier)
                            .upsert(updated);
                      },
                      child: Text(context.l10n.edit),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: persona.isDefault
                          ? null
                          : () async {
                              await ref
                                  .read(userPersonasProvider.notifier)
                                  .setDefault(persona.id);
                            },
                      child: Text(context.l10n.setAsDefault),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: ref.watch(userPersonasProvider).length <= 1
                          ? null
                          : () async {
                              await ref
                                  .read(userPersonasProvider.notifier)
                                  .delete(persona.id);
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: colors.danger,
                      ),
                      child: Text(context.l10n.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaEditorSectionTitle extends StatelessWidget {
  const _PersonaEditorSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.otColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PersonaEditorGroup extends StatelessWidget {
  const _PersonaEditorGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return DecoratedBox(
      decoration: OTStyle.flatGroupDecoration(context),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(height: 1, indent: 16, color: colors.border),
          ],
        ],
      ),
    );
  }
}

class _PersonaEditorField extends StatelessWidget {
  const _PersonaEditorField({
    required this.label,
    required this.controller,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final isMultiline = maxLines > 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
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
              color: colors.primaryText,
              fontSize: isMultiline ? 15 : 16,
              height: isMultiline ? 1.45 : 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserPersonaEditorPage extends StatefulWidget {
  const _UserPersonaEditorPage({this.existing});

  final UserPersona? existing;

  @override
  State<_UserPersonaEditorPage> createState() => _UserPersonaEditorPageState();
}

class _UserPersonaEditorPageState extends State<_UserPersonaEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _profilePromptController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _profilePromptController = TextEditingController(
      text: existing?.profilePrompt ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _profilePromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(title: Text(widget.existing == null ? context.l10n.addPersona : context.l10n.editPersona)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 28),
        children: [
          _PersonaEditorSectionTitle(context.l10n.basicInfo),
          _PersonaEditorGroup(
            children: [
              _PersonaEditorField(
                label: context.l10n.name,
                controller: _nameController,
                hintText: context.l10n.personaNameHint,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _PersonaEditorSectionTitle(context.l10n.settingsSection),
          _PersonaEditorGroup(
            children: [
              _PersonaEditorField(
                label: context.l10n.bio,
                controller: _descriptionController,
                hintText: context.l10n.bioHint,
                minLines: 2,
                maxLines: 4,
              ),
              _PersonaEditorField(
                label: context.l10n.profilePromptLabel,
                controller: _profilePromptController,
                hintText: context.l10n.profilePromptHint,
                minLines: 4,
                maxLines: 8,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
            ),
            child: Text(context.l10n.save),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final existing = widget.existing;
    final now = DateTime.now();
    Navigator.of(context).pop(
      UserPersona(
        id: existing?.id ?? 'persona-${now.microsecondsSinceEpoch}',
        name: name,
        description: _descriptionController.text.trim(),
        profilePrompt: _profilePromptController.text.trim(),
        isDefault: existing?.isDefault ?? false,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
