import 'package:flutter/material.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/models/generation_config.dart';

class GenerationConfigSheetResult {
  const GenerationConfigSheetResult._({this.config, this.reset = false});

  const GenerationConfigSheetResult.save(GenerationConfig config)
    : this._(config: config);

  const GenerationConfigSheetResult.reset() : this._(reset: true);

  final GenerationConfig? config;
  final bool reset;
}

Future<GenerationConfigSheetResult?> showGenerationConfigSheet({
  required BuildContext context,
  required String title,
  required GenerationConfig initialConfig,
  String? resetLabel,
  bool allowReset = true,
}) {
  return showModalBottomSheet<GenerationConfigSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _GenerationConfigSheet(
      title: title,
      initialConfig: initialConfig,
      resetLabel: resetLabel,
      allowReset: allowReset,
    ),
  );
}

class _GenerationConfigSheet extends StatefulWidget {
  const _GenerationConfigSheet({
    required this.title,
    required this.initialConfig,
    this.resetLabel,
    required this.allowReset,
  });

  final String title;
  final GenerationConfig initialConfig;
  final String? resetLabel;
  final bool allowReset;

  @override
  State<_GenerationConfigSheet> createState() => _GenerationConfigSheetState();
}

class _GenerationConfigSheetState extends State<_GenerationConfigSheet> {
  late double _temperature = widget.initialConfig.temperature.clamp(0.0, 2.0);
  late double _topP = widget.initialConfig.topP.clamp(0.0, 1.0);
  late double _maxTokens = widget.initialConfig.maxTokens
      .clamp(128, 8192)
      .toDouble();
  late ReasoningMode _reasoningMode = widget.initialConfig.reasoningMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _ConfigSlider(
                  label: 'Temperature',
                  valueText: _temperature.toStringAsFixed(2),
                  helperText: context.l10n.temperatureHelper,
                  value: _temperature,
                  min: 0,
                  max: 2,
                  divisions: 40,
                  onChanged: (value) => setState(() => _temperature = value),
                ),
                _ConfigSlider(
                  label: 'Top P',
                  valueText: _topP.toStringAsFixed(2),
                  helperText: context.l10n.topPHelper,
                  value: _topP,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  onChanged: (value) => setState(() => _topP = value),
                ),
                _ConfigSlider(
                  label: 'Max Tokens',
                  valueText: _maxTokens.round().toString(),
                  helperText: context.l10n.maxTokensHelper,
                  value: _maxTokens,
                  min: 128,
                  max: 8192,
                  divisions: 63,
                  onChanged: (value) => setState(() => _maxTokens = value),
                ),
                const SizedBox(height: 2),
                _ReasoningModeSelector(
                  value: _reasoningMode,
                  onChanged: (value) => setState(() => _reasoningMode = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (widget.allowReset) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pop(const GenerationConfigSheetResult.reset()),
                          child: Text(widget.resetLabel ?? context.l10n.resetToDefault),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(
                          GenerationConfigSheetResult.save(
                            GenerationConfig(
                              temperature: _temperature,
                              topP: _topP,
                              maxTokens: _maxTokens.round(),
                              reasoningMode: _reasoningMode,
                            ),
                          ),
                        ),
                        child: Text(context.l10n.save),
                      ),
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

class _ReasoningModeSelector extends StatelessWidget {
  const _ReasoningModeSelector({required this.value, required this.onChanged});

  final ReasoningMode value;
  final ValueChanged<ReasoningMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.reasoningMode,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in ReasoningMode.values)
                ChoiceChip(
                  label: Text(_reasoningModeLabel(context, mode)),
                  selected: value == mode,
                  onSelected: (_) => onChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfigSlider extends StatelessWidget {
  const _ConfigSlider({
    required this.label,
    required this.valueText,
    required this.helperText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueText;
  final String helperText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                valueText,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            helperText,
            style: TextStyle(color: colors.tertiaryText, fontSize: 12),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
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
