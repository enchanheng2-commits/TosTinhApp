import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_account.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthLogic extends ChangeNotifier {
  static const String _accountsKey = 'saved_accounts';
  static const String _currentEmailKey = 'current_account_email';

  final SharedPreferences _prefs;

  final List<UserAccount> _accounts = [];
  UserAccount? _currentUser;
  bool _loaded = false;

  AuthLogic(this._prefs);

  bool get isLoaded => _loaded;
  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<UserAccount> get accounts => List.unmodifiable(_accounts);

  static Future<AuthLogic> create() async {
    final prefs = await SharedPreferences.getInstance();
    final logic = AuthLogic(prefs);
    await logic.load();
    return logic;
  }

  Future<void> load() async {
    _accounts
      ..clear()
      ..addAll(_readAccounts());

    final currentEmail = _prefs.getString(_currentEmailKey);
    if (currentEmail != null) {
      final normalizedEmail = _normalizeEmail(currentEmail);
      _currentUser = _findAccount(normalizedEmail);
      if (_currentUser == null) {
        await _prefs.remove(_currentEmailKey);
      }
    }

    _loaded = true;
    notifyListeners();
  }

  Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _ensureLoaded();

    final normalizedEmail = _normalizeEmail(email);
    if (_findAccount(normalizedEmail) != null) {
      throw const AuthException('An account with this email already exists.');
    }

    final account = UserAccount(
      fullName: name.trim(),
      email: normalizedEmail,
      password: password,
      createdAt: DateTime.now(),
    );

    _accounts.add(account);
    _currentUser = account;
    await _persist();
    notifyListeners();
    return account;
  }

  Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    _ensureLoaded();

    final normalizedEmail = _normalizeEmail(email);
    final account = _findAccount(normalizedEmail);
    if (account == null || account.password != password) {
      throw const AuthException('Invalid email or password.');
    }

    _currentUser = account;
    await _prefs.setString(_currentEmailKey, account.email);
    notifyListeners();
    return account;
  }

  Future<void> logout() async {
    _ensureLoaded();
    _currentUser = null;
    await _prefs.remove(_currentEmailKey);
    notifyListeners();
  }

  Future<UserAccount> updateCurrentUser({
    required String fullName,
    required String email,
    String phoneNumber = '',
    String address = '',
    String? password,
  }) async {
    _ensureLoaded();

    final currentUser = _currentUser;
    if (currentUser == null) {
      throw const AuthException('No account is currently signed in.');
    }

    final normalizedEmail = _normalizeEmail(email);
    final duplicate = _accounts.any(
      (account) =>
          _normalizeEmail(account.email) == normalizedEmail &&
          account.email != currentUser.email,
    );
    if (duplicate) {
      throw const AuthException('Another account already uses this email.');
    }

    final updated = UserAccount(
      fullName: fullName.trim(),
      email: normalizedEmail,
      password: password ?? currentUser.password,
      phoneNumber: phoneNumber.trim(),
      address: address.trim(),
      createdAt: currentUser.createdAt,
    );

    final index = _accounts.indexWhere(
      (account) => account.email == currentUser.email,
    );
    if (index == -1) {
      throw const AuthException('Unable to locate the current account.');
    }

    _accounts[index] = updated;
    _currentUser = updated;
    await _persist();
    notifyListeners();
    return updated;
  }

  UserAccount? _findAccount(String normalizedEmail) {
    for (final account in _accounts) {
      if (_normalizeEmail(account.email) == normalizedEmail) {
        return account;
      }
    }
    return null;
  }

  List<UserAccount> _readAccounts() {
    final raw = _prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map>()
        .map((entry) => UserAccount.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _accountsKey,
      jsonEncode(_accounts.map((account) => account.toJson()).toList()),
    );

    if (_currentUser != null) {
      await _prefs.setString(_currentEmailKey, _currentUser!.email);
    } else {
      await _prefs.remove(_currentEmailKey);
    }
  }

  void _ensureLoaded() {
    if (!_loaded) {
      throw StateError('AuthLogic has not finished loading yet.');
    }
  }

  String _normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }
}
