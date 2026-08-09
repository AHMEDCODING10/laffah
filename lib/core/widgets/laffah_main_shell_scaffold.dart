import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/widgets/home_side_drawer.dart';
import 'laffah_bottom_navigation_bar.dart';

/// LaffahMainShellScaffold — Container scaffold wrapping StatefulNavigationShell for Laffah passenger tabs.
/// Guarantees bottom navigation bar persistence, state preservation across tab switches,
/// and full-screen drawer layering over the bottom navigation bar.
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: shellScaffoldKey,
        extendBody: true,
        drawer: HomeSideDrawer(isDark: isDark),
        body: navigationShell,
        bottomNavigationBar: LaffahBottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTabTapped(context, index),
        ),
      ),
    );
  }
}
