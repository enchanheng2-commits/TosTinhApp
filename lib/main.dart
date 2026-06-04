import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_logic.dart';
import 'cart/cart_logic.dart';
import 'favorite/favorite_logic.dart';
import 'async_module/navbar.dart';
import 'async_module/theme.dart';
import 'async_module/dark_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authLogic = await AuthLogic.create();
  runApp(MyApp(authLogic: authLogic));
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
