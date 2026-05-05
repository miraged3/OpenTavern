import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return CupertinoPageScaffold(
      backgroundColor: colors.pageBackground,
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          Expanded(child: navigationShell),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.shadowScrim,
                  border: Border(
                    top: BorderSide(color: colors.border, width: 0.5),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: CupertinoTabBar(
                    currentIndex: navigationShell.currentIndex,
                    onTap: _onTap,
                    backgroundColor: CupertinoColors.transparent,
                    activeColor: colors.accent,
                    inactiveColor: colors.tertiaryText,
                    border: null,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(CupertinoIcons.chat_bubble_2, size: 22),
                        activeIcon: const Icon(
                          CupertinoIcons.chat_bubble_2_fill,
                          size: 22,
                        ),
                        label: context.l10n.navChat,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(CupertinoIcons.person_crop_square, size: 22),
                        activeIcon: const Icon(
                          CupertinoIcons.person_crop_square_fill,
                          size: 22,
                        ),
                        label: context.l10n.navCharacters,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(CupertinoIcons.sparkles, size: 22),
                        activeIcon: const Icon(CupertinoIcons.sparkles, size: 22),
                        label: context.l10n.navMore,
                      ),
                    ],
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
