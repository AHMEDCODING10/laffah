import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'laffah_main_shell_scaffold.dart';

class LaffahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenuButton;
  final bool showBackButton;
  final List<Widget>? actions;

  const LaffahAppBar({
    super.key,
    required this.title,
    this.showMenuButton = true,
    this.showBackButton = true,
    this.actions,
  });

  void _openDrawer(BuildContext context) {
    if (LaffahMainShellScaffold.shellScaffoldKey.currentState != null) {
      LaffahMainShellScaffold.openDrawer();
    } else {
      Scaffold.maybeOf(context)?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;
    if (showMenuButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _openDrawer(context),
      );
    } else if (showBackButton) {
      leadingWidget = const BackButton();
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary500),
      leading: leadingWidget,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
