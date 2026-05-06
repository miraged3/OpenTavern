import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'l10n_extension.dart';

bool _isExitDialogOpen = false;

class AppExitGuard extends StatefulWidget {
  const AppExitGuard({required this.child, super.key});

  final Widget child;

  static Future<bool> confirmExit(BuildContext context) {
    return _showExitDialog(context);
  }

  @override
  State<AppExitGuard> createState() => _AppExitGuardState();
}

class _AppExitGuardState extends State<AppExitGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final confirmed = await _showExitDialog(context);
    return confirmed ? AppExitResponse.exit : AppExitResponse.cancel;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<bool> _showExitDialog(BuildContext context) async {
  if (_isExitDialogOpen) {
    return false;
  }
  _isExitDialogOpen = true;
  try {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(context.l10n.confirmExitTitle),
          content: Text(context.l10n.confirmExitMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.confirmExitAction),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  } finally {
    _isExitDialogOpen = false;
  }
}
