import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_logic.dart';
import 'cart/cart_logic.dart';
import 'favorite/favorite_logic.dart';
import 'async_module/navbar.dart';
import 'async_module/theme.dart';
import 'async_module/dark_login.dart';
import 'async_module/startup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<AuthLogic> _authFuture;
  late final Future<AuthLogic> _startupFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = AuthLogic.create();
    _startupFuture = _loadStartup();
  }

  Future<AuthLogic> _loadStartup() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return _authFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthLogic>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: StartupScreen(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'We could not start the app. Please restart it and try again.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          );
        }

        return MyApp(authLogic: snapshot.data!);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.authLogic});

  final AuthLogic authLogic;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authLogic),
        ChangeNotifierProvider(create: (_) => DarkLogic()),
        ChangeNotifierProvider(create: (_) => CartLogic()),
        ChangeNotifierProvider(create: (_) => FavoriteLogic()),
      ],
      child: Consumer<DarkLogic>(
        builder: (context, darkLogic, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fake Store',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: darkLogic.dark ? ThemeMode.dark : ThemeMode.light,
            home: const NavBar(),
          );
        },
      ),
    );
  }
}
