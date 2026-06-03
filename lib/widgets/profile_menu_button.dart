import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_logic.dart';
import '../auth/account_page.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

enum _ProfileAction { login, register, account, logout }

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  Future<void> _handleSelection(
    BuildContext context,
    _ProfileAction action,
  ) async {
    if (action == _ProfileAction.logout) {
      await context.read<AuthLogic>().logout();
      return;
    }

    final Widget page = switch (action) {
      _ProfileAction.login => const LoginPage(),
      _ProfileAction.register => const RegisterPage(),
      _ProfileAction.account => const AccountPage(),
      _ProfileAction.logout => const SizedBox.shrink(),
    };

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthLogic>();

    return PopupMenuButton<_ProfileAction>(
      tooltip: 'Profile',
      icon: Icon(
        auth.isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
      ),
      onSelected: (action) => _handleSelection(context, action),
      itemBuilder: (context) => [
        if (auth.currentUser != null)
          PopupMenuItem(
            enabled: false,
            child: Text(auth.currentUser!.fullName),
          ),
        if (auth.currentUser != null)
          PopupMenuItem(enabled: false, child: Text(auth.currentUser!.email)),
        if (auth.currentUser != null)
          const PopupMenuItem(
            value: _ProfileAction.account,
            child: Text('My Account'),
          ),
        if (auth.currentUser == null)
          const PopupMenuItem(
            value: _ProfileAction.login,
            child: Text('Login'),
          ),
        if (auth.currentUser == null)
          const PopupMenuItem(
            value: _ProfileAction.register,
            child: Text('Register'),
          ),
        if (auth.currentUser != null)
          PopupMenuItem(
            value: _ProfileAction.logout,
            child: const Text('Logout'),
          ),
      ],
    );
  }
}
