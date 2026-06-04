import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_logic.dart';
import '../auth/account_page.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../cart/cart_page.dart';
import '../favorite/favorite_logic.dart';
import '../cart/cart_logic.dart';
import 'favorite_page.dart';
import 'homescreen.dart';
import 'search.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 0;

  final List<Widget> pages = [const HomeScreen(), const SearchPage()];

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritePage()),
    );
  }

  void _openProfileMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Consumer<AuthLogic>(
          builder: (context, auth, _) {
            final currentUser = auth.currentUser;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentUser != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.fullName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(currentUser.email),
                          ],
                        ),
                      ),
                    ),
                  if (currentUser == null)
                    ListTile(
                      leading: const Icon(Icons.login_rounded),
                      title: const Text('Login'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  if (currentUser == null)
                    ListTile(
                      leading: const Icon(Icons.person_add_alt_1_rounded),
                      title: const Text('Register'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                    ),
                  if (currentUser != null)
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('My Account'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountPage(),
                          ),
                        );
                      },
                    ),
                  if (currentUser != null)
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: const Text('Logout'),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(sheetContext);
                        await context.read<AuthLogic>().logout();
                        if (!mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Logged out.')),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              setState(() {
                currentIndex = 0;
              });
              break;
            case 1:
              setState(() {
                currentIndex = 1;
              });
              break;
            case 2:
              _openFavorites();
              break;
            case 3:
              _openCart();
              break;
            case 4:
              _openProfileMenu();
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: "Shop",
          ),

          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Search",
          ),
          NavigationDestination(
            icon: _FavoriteNavIcon(),
            selectedIcon: _FavoriteNavIcon(active: true),
            label: "Favorites",
          ),
          NavigationDestination(
            icon: _CartNavIcon(),
            selectedIcon: _CartNavIcon(active: true),
            label: "Cart",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _FavoriteNavIcon extends StatelessWidget {
  final bool active;

  const _FavoriteNavIcon({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteLogic>(
      builder: (context, favoriteLogic, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(active ? Icons.favorite_rounded : Icons.favorite_border),
            if (favoriteLogic.totalFavorites > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    favoriteLogic.totalFavorites > 99
                        ? '99+'
                        : favoriteLogic.totalFavorites.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  final bool active;

  const _CartNavIcon({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartLogic>(
      builder: (context, cart, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              active
                  ? Icons.shopping_cart_rounded
                  : Icons.shopping_cart_outlined,
            ),
            if (cart.totalItems > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    cart.totalItems > 99 ? '99+' : cart.totalItems.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
