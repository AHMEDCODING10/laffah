import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'laffah_bottom_navigation_bar.dart';

/// LaffahMainShellScaffold — Container scaffold wrapping StatefulNavigationShell for Laffah passenger tabs.
/// Guarantees bottom navigation bar persistence, state preservation across tab switches.
class LaffahMainShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  static final GlobalKey<ScaffoldState> shellScaffoldKey =
      GlobalKey<ScaffoldState>();

  static void openDrawer() {
    shellScaffoldKey.currentState?.openDrawer();
  }

  const LaffahMainShellScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTabTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: shellScaffoldKey,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: LaffahBottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTabTapped(context, index),
        ),
      ),
    );
  }
}
