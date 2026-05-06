import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../core/llm/api_endpoint_catalog.dart';
import '../../../core/llm/provider_registry.dart';
import '../../../core/models/model_endpoint.dart';
import '../../../core/models/provider_config.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/presentation/widgets/ot_choice_sheet.dart';

class ModelSettingsPage extends ConsumerStatefulWidget {
  const ModelSettingsPage({super.key});

  @override
  ConsumerState<ModelSettingsPage> createState() => _ModelSettingsPageState();
}

class _ModelSettingsPageState extends ConsumerState<ModelSettingsPage> {
  static const Duration _modelTestTimeout = Duration(seconds: 12);

  final Set<String> _selectedIds = <String>{};
  bool _selectionMode = false;

  @override
  Widget build(BuildContext context) {
    final models = ref.watch(modelEndpointsProvider);
    final defaultModel = models.where((model) => model.isDefault).firstOrNull;
    final enabledCount = models.where((model) => model.isEnabled).length;

    return Scaffold(
      backgroundColor: OTStyle.pageBackground,
      appBar: AppBar(
        backgroundColor: OTStyle.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(context.l10n.modelSettingsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.l10n.addNew),
              style: FilledButton.styleFrom(
                backgroundColor: OTStyle.primaryText,
                foregroundColor: OTStyle.inverseText,
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: OTStyle.pillShape,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: _SummaryPanel(
                totalCount: models.length,
                enabledCount: enabledCount,
                defaultModel: defaultModel,
                selectionMode: _selectionMode,
                onTestAll: _testAllEnabled,
                onToggleSelectionMode: _toggleSelectionMode,
              ),
            ),
          ),
          if (_selectionMode)
            SliverPersistentHeader(
              pinned: true,
              delegate: _BatchBarDelegate(
                selectedCount: _selectedIds.length,
                onSelectAll: _selectAll,
                onEnable: () => _setSelectedEnabled(true),
                onDisable: () => _setSelectedEnabled(false),
                onDelete: _deleteSelected,
              ),
            ),
          if (models.isEmpty)
            const SliverToBoxAdapter(child: _EmptyModelState())
          else
            SliverList.separated(
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, index == 0 ? 2 : 0, 16, 0),
                  child: _ModelCard(
                    model: model,
                    selected: _selectedIds.contains(model.id),
                    selectionMode: _selectionMode,
                    onSelectedChanged: () => _toggleSelected(model.id),
                    onEdit: () => _openEditor(existing: model),
                    onSetDefault: () => _setDefault(model.id),
                    onToggleEnabled: () => _toggleEnabled(model.id),
                    onTest: () => _testModel(model.id),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Future<void> _openEditor({ModelEndpoint? existing}) async {
    final model = await Navigator.of(context).push<ModelEndpoint>(
      MaterialPageRoute<ModelEndpoint>(
        builder: (context) => _ModelEndpointEditorPage(existing: existing),
      ),
    );
    if (model == null || !mounted) {
      return;
    }
    await ref.read(modelEndpointsProvider.notifier).upsert(model);
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _selectAll() {
    final models = ref.read(modelEndpointsProvider);
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(models.map((model) => model.id));
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
    });
  }

  Future<void> _setSelectedEnabled(bool isEnabled) async {
    await ref
        .read(modelEndpointsProvider.notifier)
        .setSelectedEnabled(_selectedIds, isEnabled);
  }

  Future<void> _deleteSelected() async {
    await ref.read(modelEndpointsProvider.notifier).deleteMany(_selectedIds);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  Future<void> _setDefault(String id) async {
    await ref.read(modelEndpointsProvider.notifier).setDefault(id);
  }

  Future<void> _toggleEnabled(String id) async {
    final models = ref.read(modelEndpointsProvider);
    final model = models.where((item) => item.id == id).firstOrNull;
    if (model == null) {
      return;
    }
    await ref
        .read(modelEndpointsProvider.notifier)
        .updateModel(id, (item) => item.copyWith(isEnabled: !model.isEnabled));
  }

  Future<void> _testAllEnabled() async {
    final ids = ref
        .read(modelEndpointsProvider)
        .where((model) => model.isEnabled)
        .map((model) => model.id)
        .toList(growable: false);
    await Future.wait(ids.map(_testModel));
  }

  Future<void> _testModel(String id) async {
    final model = ref
        .read(modelEndpointsProvider)
        .where((item) => item.id == id)
        .firstOrNull;
    if (model == null) {
      return;
    }

    await _updateModel(
      id,
      (item) => item.copyWith(
        status: ModelEndpointStatus.testing,
        clearLatency: true,
      ),
    );

    final stopwatch = Stopwatch()..start();
    try {
      final provider = ref
          .read(providerRegistryProvider)
          .create(
            ProviderConfig(
              id: model.id,
              label: model.name,
              type: model.providerType,
              apiFormat: model.apiFormat,
              baseUrl: model.baseUrl,
              defaultModel: model.model,
              apiKey: model.apiKey,
            ),
          );
      await provider.listModels().timeout(_modelTestTimeout);
      stopwatch.stop();
      if (!mounted) {
        return;
      }
      await _updateModel(
        id,
        (item) => item.copyWith(
          status: ModelEndpointStatus.available,
          latencyMs: stopwatch.elapsedMilliseconds,
        ),
      );
    } catch (_) {
      stopwatch.stop();
      if (!mounted) {
        return;
      }
      await _updateModel(
        id,
        (item) => item.copyWith(
          status: ModelEndpointStatus.failed,
          latencyMs: stopwatch.elapsedMilliseconds,
        ),
      );
    }
  }

  Future<void> _updateModel(
    String id,
    ModelEndpoint Function(ModelEndpoint) update,
  ) {
    return ref.read(modelEndpointsProvider.notifier).updateModel(id, update);
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.totalCount,
    required this.enabledCount,
    required this.defaultModel,
    required this.selectionMode,
    required this.onTestAll,
    required this.onToggleSelectionMode,
  });

  final int totalCount;
  final int enabledCount;
  final ModelEndpoint? defaultModel;
  final bool selectionMode;
  final VoidCallback onTestAll;
  final VoidCallback onToggleSelectionMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OTStyle.pageBackground,
        border: Border.all(color: OTStyle.border),
        borderRadius: BorderRadius.circular(OTStyle.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.defaultModel,
              style: TextStyle(color: OTStyle.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 5),
            Text(
              defaultModel?.name ?? context.l10n.notSet,
              style: TextStyle(
                color: OTStyle.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              defaultModel == null
                  ? context.l10n.noDefaultModel
                  : '${defaultModel!.model} · ${apiFormatLabel(defaultModel!.apiFormat)}',
              style: TextStyle(color: OTStyle.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _CountPill(
                  label: context.l10n.modelsCountLabel,
                  value: totalCount,
                ),
                const SizedBox(width: 8),
                _CountPill(
                  label: context.l10n.enabledCountLabel,
                  value: enabledCount,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: totalCount == 0 ? null : onTestAll,
                    style: FilledButton.styleFrom(
                      backgroundColor: OTStyle.primaryText,
                      foregroundColor: OTStyle.inverseText,
                      disabledBackgroundColor: OTStyle.border,
                      disabledForegroundColor: OTStyle.tertiaryText,
                      minimumSize: const Size(0, 42),
                      shape: OTStyle.pillShape,
                    ),
                    child: Text(context.l10n.testAllEnabled),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: totalCount == 0 ? null : onToggleSelectionMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OTStyle.primaryText,
                    side: BorderSide(color: OTStyle.strongBorder),
                    minimumSize: const Size(76, 42),
                    shape: OTStyle.pillShape,
                  ),
                  child: Text(
                    selectionMode
                        ? context.l10n.done
                        : context.l10n.batchManage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: OTStyle.mutedFill,
          borderRadius: BorderRadius.circular(OTStyle.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: OTStyle.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(color: OTStyle.secondaryText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyModelState extends StatelessWidget {
  const _EmptyModelState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: OTStyle.pageBackground,
              border: Border.all(color: OTStyle.border),
              borderRadius: BorderRadius.circular(OTStyle.cardRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.noModelsYet,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    context.l10n.addApiModelKey,
                    style: TextStyle(
                      color: OTStyle.secondaryText,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchBarDelegate extends SliverPersistentHeaderDelegate {
  static const double _extent = 56;

  const _BatchBarDelegate({
    required this.selectedCount,
    required this.onSelectAll,
    required this.onEnable,
    required this.onDisable,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onDelete;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.otColors;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                context.l10n.selectedItemsCount(selectedCount),
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _BatchButton(
                label: context.l10n.selectAll,
                onPressed: onSelectAll,
              ),
              _BatchButton(label: context.l10n.enable, onPressed: onEnable),
              _BatchButton(label: context.l10n.disable, onPressed: onDisable),
              _BatchButton(
                label: context.l10n.delete,
                color: colors.danger,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_BatchBarDelegate oldDelegate) {
    return selectedCount != oldDelegate.selectedCount;
  }
}

class _BatchButton extends StatelessWidget {
  const _BatchButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? OTStyle.primaryText,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.selected,
    required this.selectionMode,
    required this.onSelectedChanged,
    required this.onEdit,
    required this.onSetDefault,
    required this.onToggleEnabled,
    required this.onTest,
  });

  final ModelEndpoint model;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onSelectedChanged;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onToggleEnabled;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selectionMode ? onSelectedChanged : onEdit,
      borderRadius: BorderRadius.circular(OTStyle.cardRadius),
      child: Ink(
        decoration: BoxDecoration(
          color: OTStyle.pageBackground,
          borderRadius: BorderRadius.circular(OTStyle.cardRadius),
          border: Border.all(
            color: selected ? OTStyle.primaryText : OTStyle.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProviderAvatar(label: providerLabel(model.providerType)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: OTStyle.primaryText,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          model.model,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: OTStyle.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectionMode)
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected
                          ? OTStyle.primaryText
                          : OTStyle.tertiaryText,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (model.isDefault) const _DefaultBadge(),
                          if (model.isDefault) const SizedBox(height: 8),
                          _StatusBadge(model: model),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                modelTypeLabel(model),
                style: TextStyle(
                  color: OTStyle.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${model.baseUrl} · ${model.apiKeyFingerprint}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: OTStyle.secondaryText, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: onTest,
                    style: TextButton.styleFrom(
                      foregroundColor: OTStyle.primaryText,
                      minimumSize: const Size(0, 34),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      model.status == ModelEndpointStatus.testing
                          ? context.l10n.testing
                          : context.l10n.test,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: model.isDefault ? null : onSetDefault,
                    style: TextButton.styleFrom(
                      foregroundColor: OTStyle.primaryText,
                      minimumSize: const Size(0, 34),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(context.l10n.setAsDefault),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                    value: model.isEnabled,
                    activeThumbColor: OTStyle.inverseText,
                    activeTrackColor: OTStyle.primaryText,
                    onChanged: (_) {
                      HapticFeedback.selectionClick();
                      onToggleEnabled();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: OTStyle.primaryText,
      child: Text(
        label.characters.first.toUpperCase(),
        style: TextStyle(
          color: OTStyle.inverseText,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OTStyle.primaryText,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          context.l10n.defaultBadge,
          style: TextStyle(
            color: OTStyle.inverseText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.model});

  final ModelEndpoint model;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (model.status) {
      ModelEndpointStatus.available => (
        model.latencyMs == null
            ? context.l10n.available
            : '${model.latencyMs}ms',
        OTStyle.success,
      ),
      ModelEndpointStatus.failed => (context.l10n.failed, OTStyle.danger),
      ModelEndpointStatus.testing => (context.l10n.testing, OTStyle.inProgress),
      ModelEndpointStatus.unknown => (
        context.l10n.untested,
        OTStyle.secondaryText,
      ),
    };

    return Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
    );
  }
}

class _ModelEndpointEditorPage extends StatefulWidget {
  const _ModelEndpointEditorPage({this.existing});

  final ModelEndpoint? existing;

  @override
  State<_ModelEndpointEditorPage> createState() =>
      _ModelEndpointEditorPageState();
}

class _ModelEndpointEditorPageState extends State<_ModelEndpointEditorPage> {
  static final List<ApiEndpointPreset> _cloudPresets = apiEndpointPresets
      .where((preset) => preset.group == ApiEndpointPresetGroup.cloud)
      .toList(growable: false);
  static final List<CloudVendorId> _cloudVendors = CloudVendorId.values;

  late final TextEditingController _nameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  late final TextEditingController _apiKeyController;
  late ConnectionSource _connectionSource;
  late CloudVendorId _cloudVendor;
  ApiEndpointPreset? _cloudPreset;
  late ApiEndpointFormat _customApiFormat;
  late bool _isEnabled;
  late bool _isDefault;
  List<String> _availableModels = const <String>[];
  bool _isFetchingModels = false;
  String? _fetchModelsError;
  String? _formError;
  String? _nameError;
  String? _baseUrlError;
  String? _modelError;
  bool _nameFollowsModelSelection = false;
  bool _isUpdatingSuggestedName = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final selection = EditorEndpointSelection.fromModel(existing);
    _nameController = TextEditingController(text: existing?.name ?? '');
    _baseUrlController = TextEditingController(text: existing?.baseUrl ?? '');
    _modelController = TextEditingController(text: existing?.model ?? '');
    _nameFollowsModelSelection = existing == null;
    _nameController.addListener(_handleDraftChanged);
    _baseUrlController.addListener(_handleDraftChanged);
    _modelController.addListener(_handleDraftChanged);
    _nameController.addListener(_handleNameEdited);
    _nameController.addListener(() {
      if (_nameError != null || _formError != null) {
        setState(() {
          _nameError = null;
          _formError = null;
        });
      }
    });
    _baseUrlController.addListener(() {
      if (_baseUrlError != null || _formError != null) {
        setState(() {
          _baseUrlError = null;
          _formError = null;
        });
      }
    });
    _modelController.addListener(_handleModelChanged);
    _modelController.addListener(() {
      if (_modelError != null || _formError != null) {
        setState(() {
          _modelError = null;
          _formError = null;
        });
      }
    });
    _apiKeyController = TextEditingController();
    _connectionSource = selection.connectionSource;
    _cloudVendor = selection.cloudVendor;
    _cloudPreset = selection.cloudPreset;
    _customApiFormat = selection.customApiFormat;
    _isEnabled = existing?.isEnabled ?? true;
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_handleDraftChanged)
      ..removeListener(_handleNameEdited)
      ..dispose();
    _baseUrlController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _modelController
      ..removeListener(_handleDraftChanged)
      ..removeListener(_handleModelChanged)
      ..dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Scaffold(
      backgroundColor: OTStyle.pageBackground,
      appBar: AppBar(
        backgroundColor: OTStyle.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? context.l10n.editModel : context.l10n.addModel,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _canSaveDraft ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryText,
                foregroundColor: colors.inverseText,
                disabledBackgroundColor: colors.border,
                disabledForegroundColor: colors.tertiaryText,
                minimumSize: const Size(64, 36),
                shape: OTStyle.pillShape,
              ),
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: _EditorIntroCard(
              title: _isEditing
                  ? _nameController.text.trim()
                  : context.l10n.configureModelEndpoint,
              subtitle: _connectionSource == ConnectionSource.cloud
                  ? context.l10n.cloudDescription
                  : context.l10n.customUrlDescription,
              badge: _connectionSource.label,
            ),
          ),
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: _EditorErrorBanner(message: _formError!),
            ),
          _FormSection(
            title: context.l10n.connection,
            children: [
              _PickerRow(
                label: context.l10n.connectionSource,
                value: _connectionSource.label,
                onTap: () => _pickConnectionSource(context),
              ),
              if (_connectionSource == ConnectionSource.cloud) ...[
                _PickerRow(
                  label: context.l10n.cloudVendor,
                  value: cloudVendorLabel(_cloudVendor),
                  onTap: () => _pickCloudVendor(context),
                ),
                _InfoRow(
                  label: context.l10n.baseUrl,
                  value: _cloudPreset?.baseUrl ?? '-',
                ),
              ] else ...[
                _PickerRow(
                  label: context.l10n.apiFormat,
                  value: apiFormatLabel(_customApiFormat),
                  onTap: () => _pickCustomApiFormat(context),
                ),
              ],
              if (_connectionSource == ConnectionSource.customUrl)
                _TextFieldRow(
                  label: context.l10n.baseUrl,
                  controller: _baseUrlController,
                  placeholder: _baseUrlPlaceholder,
                  keyboardType: TextInputType.url,
                  errorText: _baseUrlError,
                ),
              _TextFieldRow(
                label: context.l10n.apiKey,
                controller: _apiKeyController,
                placeholder: _isEditing
                    ? context.l10n.keepExistingKey
                    : 'sk-...',
                obscureText: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ModelDiscoverySection(
            isFetching: _isFetchingModels,
            error: _fetchModelsError,
            models: _availableModels,
            selectedModel: _modelController.text.trim(),
            onFetch: _fetchAvailableModels,
            onSelect: _selectDiscoveredModel,
          ),
          const SizedBox(height: 18),
          _FormSection(
            title: context.l10n.models,
            children: [
              _TextFieldRow(
                label: context.l10n.name,
                controller: _nameController,
                placeholder: _namePlaceholder(context),
                errorText: _nameError,
              ),
              _TextFieldRow(
                label: context.l10n.modelId,
                controller: _modelController,
                placeholder: _modelPlaceholder,
                errorText: _modelError,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FormSection(
            title: context.l10n.status,
            children: [
              _SwitchRow(
                label: context.l10n.enableSwitch,
                value: _isEnabled,
                onChanged: (value) => setState(() => _isEnabled = value),
              ),
              _SwitchRow(
                label: context.l10n.setDefaultSwitch,
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ApiEndpointFormat get _effectiveApiFormat {
    return _connectionSource == ConnectionSource.cloud
        ? _cloudPreset?.apiFormat ?? ApiEndpointFormat.openAiChatCompletions
        : _customApiFormat;
  }

  ProviderType get _effectiveProviderType {
    if (_connectionSource == ConnectionSource.cloud) {
      return _cloudPreset?.providerType ?? ProviderType.openAi;
    }
    return switch (_customApiFormat) {
      ApiEndpointFormat.openAiChatCompletions => ProviderType.openAiCompatible,
      ApiEndpointFormat.openAiResponses => ProviderType.openAi,
      ApiEndpointFormat.anthropicMessages => ProviderType.anthropic,
      ApiEndpointFormat.geminiGenerateContent => ProviderType.gemini,
      ApiEndpointFormat.cohereV2Chat => ProviderType.cohere,
    };
  }

  ApiEndpointPreset? get _activePreset {
    return _connectionSource == ConnectionSource.cloud ? _cloudPreset : null;
  }

  bool get _canSaveDraft {
    return _nameController.text.trim().isNotEmpty &&
        _resolvedBaseUrl.trim().isNotEmpty &&
        _modelController.text.trim().isNotEmpty;
  }

  String get _resolvedBaseUrl {
    return _connectionSource == ConnectionSource.cloud
        ? (_cloudPreset?.baseUrl ?? _baseUrlController.text.trim())
        : _baseUrlController.text.trim();
  }

  String get _baseUrlPlaceholder {
    return switch (_customApiFormat) {
      ApiEndpointFormat.openAiChatCompletions => 'https://api.example.com/v1',
      ApiEndpointFormat.openAiResponses => 'https://api.example.com/v1',
      ApiEndpointFormat.anthropicMessages => 'https://api.anthropic.com',
      ApiEndpointFormat.geminiGenerateContent =>
        'https://generativelanguage.googleapis.com/v1beta',
      ApiEndpointFormat.cohereV2Chat => 'https://api.cohere.com',
    };
  }

  String _namePlaceholder(BuildContext context) {
    return switch (_connectionSource) {
      ConnectionSource.cloud => context.l10n.cloudVendorModelExample,
      ConnectionSource.customUrl =>
        '${context.l10n.customUrlExamplePrefix} ${apiFormatLabel(_customApiFormat)}',
    };
  }

  String get _modelPlaceholder {
    return _activePreset?.exampleModel ?? 'e.g. gpt-4o';
  }

  Future<void> _pickConnectionSource(BuildContext context) async {
    final picked = await _showChoiceSheet<ConnectionSource>(
      context: context,
      title: context.l10n.connectionSource,
      values: ConnectionSource.values,
      labelBuilder: (value) => value.label,
    );
    if (picked != null) {
      setState(() {
        _connectionSource = picked;
        if (picked == ConnectionSource.cloud) {
          _cloudPreset = _syncCloudPresetForVendor();
          _baseUrlController.text = _cloudPreset?.baseUrl ?? '';
        }
      });
    }
  }

  Future<void> _pickCloudVendor(BuildContext context) async {
    final picked = await _showChoiceSheet<CloudVendorId>(
      context: context,
      title: context.l10n.cloudVendor,
      values: _cloudVendors,
      labelBuilder: cloudVendorLabel,
    );
    if (picked != null) {
      setState(() {
        _cloudVendor = picked;
        _cloudPreset = _syncCloudPresetForVendor();
        _baseUrlController.text = _cloudPreset?.baseUrl ?? '';
      });
    }
  }

  ApiEndpointPreset? _syncCloudPresetForVendor() {
    return _cloudPresets
        .where((preset) => preset.cloudVendorId == _cloudVendor)
        .firstOrNull;
  }

  Future<void> _pickCustomApiFormat(BuildContext context) async {
    final picked = await _showChoiceSheet<ApiEndpointFormat>(
      context: context,
      title: context.l10n.apiFormat,
      values: ApiEndpointFormat.values,
      labelBuilder: apiFormatLabel,
    );
    if (picked != null) {
      setState(() {
        _customApiFormat = picked;
      });
    }
  }

  void _handleModelChanged() {
    if (_availableModels.isNotEmpty) {
      setState(() {});
    }
  }

  void _handleDraftChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleNameEdited() {
    if (_isUpdatingSuggestedName) {
      return;
    }

    final name = _nameController.text.trim();
    final model = _modelController.text.trim();
    _nameFollowsModelSelection = name.isEmpty || name == model;
  }

  Future<void> _fetchAvailableModels() async {
    final baseUrl = _resolvedBaseUrl;
    if (baseUrl.isEmpty) {
      setState(() => _fetchModelsError = context.l10n.enterBaseUrlFirst);
      return;
    }

    final resolvedApiKey = _apiKeyController.text.trim().isEmpty
        ? widget.existing?.apiKey
        : _apiKeyController.text.trim();

    setState(() {
      _isFetchingModels = true;
      _fetchModelsError = null;
    });

    try {
      final provider = const ProviderRegistry().create(
        ProviderConfig(
          id: 'model-discovery',
          label: _activePreset?.name ?? _connectionSource.label,
          type: _effectiveProviderType,
          apiFormat: _effectiveApiFormat,
          baseUrl: baseUrl,
          defaultModel: _modelController.text.trim(),
          apiKey: resolvedApiKey,
        ),
      );
      final models = await provider.listModels();
      if (!mounted) {
        return;
      }
      setState(() {
        _availableModels = models;
        _fetchModelsError = models.isEmpty
            ? context.l10n.noModelsReturned
            : null;
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _fetchModelsError = _describeDioError(context.l10n, error),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _fetchModelsError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isFetchingModels = false);
      }
    }
  }

  void _selectDiscoveredModel(String model) {
    final previousModel = _modelController.text.trim();
    final shouldSyncName =
        _nameFollowsModelSelection ||
        _nameController.text.trim().isEmpty ||
        _nameController.text.trim() == previousModel;
    setState(() {
      _modelController.text = model;
      if (shouldSyncName) {
        _isUpdatingSuggestedName = true;
        _nameController.text = model;
        _isUpdatingSuggestedName = false;
        _nameFollowsModelSelection = true;
      }
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    final model = _modelController.text.trim();
    final resolvedBaseUrl = _resolvedBaseUrl;
    final nameError = name.isEmpty ? context.l10n.enterModelName : null;
    final baseUrlError = resolvedBaseUrl.isEmpty
        ? context.l10n.enterBaseUrl
        : null;
    final modelError = model.isEmpty ? context.l10n.enterModelId : null;
    if (nameError != null || baseUrlError != null || modelError != null) {
      setState(() {
        _nameError = nameError;
        _baseUrlError = baseUrlError;
        _modelError = modelError;
        _formError = context.l10n.completeRequiredFields;
      });
      return;
    }

    final existing = widget.existing;
    final key = _apiKeyController.text.trim();
    final storedApiKey = key.isEmpty ? existing?.apiKey : key;
    final fingerprint = key.isEmpty
        ? existing?.apiKeyFingerprint ?? 'No Key'
        : _fingerprintKey(key);

    Navigator.of(context).pop(
      ModelEndpoint(
        id: existing?.id ?? 'model-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        providerType: _effectiveProviderType,
        apiFormat: _effectiveApiFormat,
        baseUrl: resolvedBaseUrl,
        model: model,
        apiKey: storedApiKey,
        apiKeyLabel: existing?.apiKeyLabel ?? 'Unnamed Key',
        apiKeyFingerprint: fingerprint,
        isEnabled: _isEnabled,
        isDefault: _isDefault,
        status: existing?.status ?? ModelEndpointStatus.unknown,
        latencyMs: existing?.latencyMs,
      ),
    );
  }
}

String _describeDioError(AppLocalizations l10n, DioException error) {
  final rawMessage = error.message?.trim();

  // 处理连接错误
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout) {
    final base = l10n.connectionFailed;
    return rawMessage == null || rawMessage.isEmpty
        ? base
        : '$base\n${l10n.originalError}: $rawMessage';
  }

  // 处理超时错误
  if (error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return l10n.requestTimeoutColon;
  }

  // 处理取消错误
  if (error.type == DioExceptionType.cancel) {
    return l10n.requestCancelled;
  }

  // 处理 HTTP 状态码错误
  final status = error.response?.statusCode;
  final data = error.response?.data;

  if (status != null) {
    final statusMsg = switch (status) {
      401 => l10n.authFailed,
      403 => l10n.permissionDenied,
      404 => l10n.endpointNotFound,
      429 => l10n.rateLimitReached,
      500 => l10n.serverInternalError,
      502 || 503 || 504 => l10n.serviceUnavailable,
      _ => '${l10n.fetchFailed} ($status)',
    };

    if (data != null && data is Map && data['error'] != null) {
      return '$statusMsg: ${data['error']}';
    }
    return statusMsg;
  }

  // 其他错误
  return '${l10n.fetchFailed}: ${error.message ?? 'unknown error'}';
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        DecoratedBox(
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
        ),
      ],
    );
  }
}

class _ModelDiscoverySection extends StatelessWidget {
  const _ModelDiscoverySection({
    required this.isFetching,
    required this.error,
    required this.models,
    required this.selectedModel,
    required this.onFetch,
    required this.onSelect,
  });

  final bool isFetching;
  final String? error;
  final List<String> models;
  final String selectedModel;
  final VoidCallback onFetch;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Text(
                context.l10n.availableModels,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: isFetching ? null : onFetch,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primaryText,
                  backgroundColor: colors.mutedFill,
                  disabledBackgroundColor: colors.mutedFill,
                  disabledForegroundColor: colors.tertiaryText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: const Size(96, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  isFetching
                      ? context.l10n.fetchingModels
                      : context.l10n.fetchModels,
                ),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.danger.withValues(alpha: 0.18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: colors.danger,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        if (models.isEmpty && error == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.mutedFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Text(
                  context.l10n.confirmConnectionThenFetch,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        if (models.isNotEmpty)
          DecoratedBox(
            decoration: OTStyle.flatGroupDecoration(context),
            child: Column(
              children: [
                for (var index = 0; index < models.length; index++) ...[
                  _DiscoveredModelRow(
                    model: models[index],
                    selected: models[index] == selectedModel,
                    onTap: () => onSelect(models[index]),
                  ),
                  if (index != models.length - 1)
                    Divider(height: 1, indent: 16, color: colors.border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _EditorIntroCard extends StatelessWidget {
  const _EditorIntroCard({
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final resolvedTitle = title.trim().isEmpty
        ? context.l10n.configureModelEndpoint
        : title.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(OTStyle.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.mutedFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: colors.primaryText,
                size: 20,
              ),
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
                          resolvedTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.mutedFill,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorErrorBanner extends StatelessWidget {
  const _EditorErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.danger.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: colors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.danger,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveredModelRow extends StatelessWidget {
  const _DiscoveredModelRow({
    required this.model,
    required this.selected,
    required this.onTap,
  });

  final String model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primaryText.withValues(alpha: 0.05),
        highlightColor: colors.primaryText.withValues(alpha: 0.025),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, size: 20, color: colors.primaryText),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorRowSurface extends StatelessWidget {
  const _EditorRowSurface({required this.child, this.onTap});

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
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

class _TextFieldRow extends StatelessWidget {
  const _TextFieldRow({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return _EditorRowSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 88,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    textAlign: TextAlign.right,
                    scrollPadding: EdgeInsets.zero,
                    style: TextStyle(color: colors.primaryText),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(color: colors.secondaryText),
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 88),
                child: Text(
                  errorText!,
                  style: TextStyle(
                    color: colors.danger,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
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
    return _EditorRowSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(
                label,
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.secondaryText),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colors.tertiaryText,
            ),
          ],
        ),
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
    final colors = context.otColors;
    return _EditorRowSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
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
    );
  }
}

Future<T?> _showChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> values,
  required String Function(T value) labelBuilder,
}) {
  return showOtChoiceSheet(
    context: context,
    title: title,
    values: values,
    labelBuilder: labelBuilder,
  );
}

String _fingerprintKey(String key) {
  if (key.length <= 8) {
    return '...$key';
  }
  return '${key.substring(0, 3)}...${key.substring(key.length - 4)}';
}

enum ConnectionSource { cloud, customUrl }

extension ConnectionSourceLabel on ConnectionSource {
  String get label {
    return switch (this) {
      ConnectionSource.cloud => 'Cloud',
      ConnectionSource.customUrl => 'Custom URL',
    };
  }
}

class EditorEndpointSelection {
  const EditorEndpointSelection({
    required this.connectionSource,
    required this.cloudVendor,
    required this.cloudPreset,
    required this.customApiFormat,
  });

  final ConnectionSource connectionSource;
  final CloudVendorId cloudVendor;
  final ApiEndpointPreset? cloudPreset;
  final ApiEndpointFormat customApiFormat;

  static EditorEndpointSelection fromModel(ModelEndpoint? model) {
    if (model == null) {
      return EditorEndpointSelection(
        connectionSource: ConnectionSource.cloud,
        cloudVendor: CloudVendorId.openAi,
        cloudPreset: apiEndpointPresets
            .where((preset) => preset.cloudVendorId == CloudVendorId.openAi)
            .firstOrNull,
        customApiFormat: ApiEndpointFormat.openAiChatCompletions,
      );
    }

    final exactPreset = apiEndpointPresets.where((preset) {
      return preset.providerType == model.providerType &&
          preset.apiFormat == model.apiFormat &&
          preset.baseUrl == model.baseUrl;
    }).firstOrNull;
    if (exactPreset != null) {
      return EditorEndpointSelection(
        connectionSource: exactPreset.group == ApiEndpointPresetGroup.cloud
            ? ConnectionSource.cloud
            : ConnectionSource.customUrl,
        cloudVendor: exactPreset.cloudVendorId ?? CloudVendorId.openAi,
        cloudPreset: exactPreset.group == ApiEndpointPresetGroup.cloud
            ? exactPreset
            : null,
        customApiFormat: exactPreset.apiFormat,
      );
    }

    return EditorEndpointSelection(
      connectionSource: ConnectionSource.customUrl,
      cloudVendor: CloudVendorId.openAi,
      cloudPreset: null,
      customApiFormat: model.apiFormat,
    );
  }
}

String cloudVendorLabel(CloudVendorId vendor) {
  return switch (vendor) {
    CloudVendorId.openAi => 'OpenAI',
    CloudVendorId.anthropic => 'Anthropic',
    CloudVendorId.gemini => 'Gemini',
    CloudVendorId.cohere => 'Cohere',
    CloudVendorId.mistral => 'Mistral',
    CloudVendorId.deepSeek => 'DeepSeek',
    CloudVendorId.openRouter => 'OpenRouter',
    CloudVendorId.groq => 'Groq',
  };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: OTStyle.rowMinHeight),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          child: Row(
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: colors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String providerLabel(ProviderType type) {
  return switch (type) {
    ProviderType.openAi => 'OpenAI',
    ProviderType.openAiCompatible => 'OpenAI-Compatible',
    ProviderType.anthropic => 'Anthropic',
    ProviderType.gemini => 'Gemini',
    ProviderType.cohere => 'Cohere',
    ProviderType.mistral => 'Mistral',
    ProviderType.deepSeek => 'DeepSeek',
    ProviderType.openRouter => 'OpenRouter',
    ProviderType.groq => 'Groq',
    ProviderType.ollama => 'Ollama',
    ProviderType.lmStudio => 'LM Studio',
    ProviderType.koboldCpp => 'KoboldCpp',
    ProviderType.vllm => 'vLLM',
    ProviderType.custom => 'Custom',
  };
}

String modelTypeLabel(ModelEndpoint model) {
  return switch (model.providerType) {
    ProviderType.openAiCompatible => apiFormatLabel(model.apiFormat),
    ProviderType.custom => apiFormatLabel(model.apiFormat),
    _ => providerLabel(model.providerType),
  };
}

String apiFormatLabel(ApiEndpointFormat format) {
  return switch (format) {
    ApiEndpointFormat.openAiChatCompletions => 'OpenAI Chat',
    ApiEndpointFormat.openAiResponses => 'OpenAI Responses',
    ApiEndpointFormat.anthropicMessages => 'Anthropic Messages',
    ApiEndpointFormat.geminiGenerateContent => 'Gemini Content',
    ApiEndpointFormat.cohereV2Chat => 'Cohere v2 Chat',
  };
}
