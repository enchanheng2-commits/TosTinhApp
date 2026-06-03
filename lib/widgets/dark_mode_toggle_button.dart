import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../async_module/dark_login.dart';

class DarkModeToggleButton extends StatelessWidget {
  const DarkModeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<DarkLogic>().dark;

    return IconButton(
      onPressed: () => context.read<DarkLogic>().toggleDark(),
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}
