import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/generation_config.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/widgets/generation_config_sheet.dart';
import '../../../shared/presentation/widgets/ot_choice_sheet.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(modelEndpointsProvider);
    final themePreference = ref.watch(themePreferenceProvider);
    final languagePreference = ref.watch(languagePreferenceProvider);
    final loggingEnabled = ref.watch(appLoggingEnabledProvider);
    final logCount = ref.watch(appLogsProvider).length;
    final generationConfig = ref.watch(defaultGenerationConfigProvider);
    final colors = context.otColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
        children: [
          _SectionTitle(context.l10n.appearance),
          _FlatGroup(
            children: [
              _SelectionRow(
                label: context.l10n.language,
                value: _languagePreferenceLabel(context, languagePreference),
                onTap: () =>
                    _pickLanguagePreference(context, ref, languagePreference),
              ),
              _SelectionRow(
                label: context.l10n.themeMode,
                value: _themePreferenceLabel(context, themePreference),
                onTap: () =>
                    _pickThemePreference(context, ref, themePreference),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(context.l10n.user),
          _FlatGroup(
            children: [
              _NavigationRow(
                label: context.l10n.userPersonas,
                value: context.l10n.userPersonasCount(
                  ref.watch(userPersonasProvider).length,
                ),
                icon: Icons.badge_outlined,
                onTap: () => context.pushNamed('user_personas'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(context.l10n.models),
          _FlatGroup(
            children: [
              _NavigationRow(
                label: context.l10n.modelSettings,
                value: context.l10n.modelCount(models.length),
                icon: Icons.account_tree_outlined,
                onTap: () => context.pushNamed('model_settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(context.l10n.chat),
          _FlatGroup(
            children: [
              _ToggleRow(
                label: context.l10n.enterKeyToSend,
                value: ref.watch(enterKeyToSendProvider),
                onChanged: (value) =>
                    ref.read(enterKeyToSendProvider.notifier).setValue(value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(context.l10n.logs),
          _FlatGroup(
            children: [
              _ToggleRow(
                label: context.l10n.enableLogging,
                value: loggingEnabled,
                onChanged: (value) => ref
                    .read(appLoggingEnabledProvider.notifier)
                    .setValue(value),
              ),
              _NavigationRow(
                label: context.l10n.viewLogs,
                value: context.l10n.logCount(logCount),
                icon: Icons.article_outlined,
                onTap: () => context.pushNamed('app_logs'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(context.l10n.generationParams),
          _FlatGroup(
            children: [
              _SelectionRow(
                label: context.l10n.temperature,
                value: generationConfig.temperature.toStringAsFixed(2),
                onTap: () =>
                    _editGenerationConfig(context, ref, generationConfig),
              ),
              _SelectionRow(
                label: context.l10n.topP,
                value: generationConfig.topP.toStringAsFixed(2),
                onTap: () =>
                    _editGenerationConfig(context, ref, generationConfig),
              ),
              _SelectionRow(
                label: context.l10n.maxTokens,
                value: generationConfig.maxTokens.toString(),
                onTap: () =>
                    _editGenerationConfig(context, ref, generationConfig),
              ),
              _SelectionRow(
                label: context.l10n.reasoningMode,
                value: _reasoningModeLabel(
                  context,
                  generationConfig.reasoningMode,
                ),
                onTap: () =>
                    _editGenerationConfig(context, ref, generationConfig),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickLanguagePreference(
    BuildContext context,
    WidgetRef ref,
    AppLanguagePreference current,
  ) async {
    final next = await showOtChoiceSheet<AppLanguagePreference>(
      context: context,
      title: context.l10n.language,
      values: AppLanguagePreference.values,
      labelBuilder: (p) => _languagePreferenceLabel(context, p),
    );
    if (next == null || next == current) {
      return;
    }
    await ref.read(languagePreferenceProvider.notifier).setPreference(next);
  }

  String _languagePreferenceLabel(
    BuildContext context,
    AppLanguagePreference preference,
  ) {
    return switch (preference) {
      AppLanguagePreference.system => context.l10n.languageSystem,
      AppLanguagePreference.en => context.l10n.languageEnglish,
      AppLanguagePreference.zh => context.l10n.languageChinese,
    };
  }

  Future<void> _pickThemePreference(
    BuildContext context,
    WidgetRef ref,
    AppThemePreference current,
  ) async {
    final next = await showOtChoiceSheet<AppThemePreference>(
      context: context,
      title: context.l10n.themeMode,
      values: AppThemePreference.values,
      labelBuilder: (p) => _themePreferenceLabel(context, p),
    );
    if (next == null || next == current) {
      return;
    }
    await ref.read(themePreferenceProvider.notifier).setPreference(next);
  }

  String _themePreferenceLabel(
    BuildContext context,
    AppThemePreference preference,
  ) {
    return switch (preference) {
      AppThemePreference.system => context.l10n.themeSystem,
      AppThemePreference.light => context.l10n.themeLight,
      AppThemePreference.dark => context.l10n.themeDark,
    };
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

  Future<void> _editGenerationConfig(
    BuildContext context,
    WidgetRef ref,
    GenerationConfig current,
  ) async {
    final result = await showGenerationConfigSheet(
      context: context,
      title: context.l10n.defaultGenerationParams,
      initialConfig: current,
      resetLabel: context.l10n.resetToDefault,
    );
    if (result == null) {
      return;
    }
    await ref
        .read(defaultGenerationConfigProvider.notifier)
        .setConfig(result.reset ? const GenerationConfig() : result.config!);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: Text(
        text,
        style: OTStyle.textStyle(
          color: colors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SettingsRowSurface extends StatelessWidget {
  const _SettingsRowSurface({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primaryText.withValues(alpha: 0.05),
        highlightColor: colors.primaryText.withValues(alpha: 0.025),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OTStyle.rowMinHeight),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  const _NavigationRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return _SettingsRowSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.secondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: OTStyle.textStyle(
                  color: colors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: OTStyle.textStyle(
                color: colors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.tertiaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlatGroup extends StatelessWidget {
  const _FlatGroup({required this.children});

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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return _SettingsRowSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: OTStyle.textStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: (nextValue) {
                  HapticFeedback.selectionClick();
                  onChanged(nextValue);
                },
                activeThumbColor: colors.inverseText,
                activeTrackColor: colors.primaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return _SettingsRowSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: OTStyle.textStyle(
                  color: colors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: OTStyle.textStyle(
                color: colors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.tertiaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
