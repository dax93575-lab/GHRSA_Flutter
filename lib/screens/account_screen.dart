import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isGuest = appProvider.isGuest;
        final userName =
            appProvider.userName ?? 'أحمد علي'; // Default if not guest
        final userEmail = appProvider.userEmail ?? 'user@example.com';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'حسابي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green[800],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // User Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.green[800],
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isGuest ? Icons.person_off : Icons.person,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest ? 'زائر' : userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isGuest)
                            Text(
                              userEmail,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          if (isGuest)
                            const Text(
                              'سجل للحصول على كامل الميزات',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // User Options
                _buildListTile(Icons.shopping_bag_outlined, 'طلباتي', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  );
                }),
                _buildListTile(Icons.favorite_border, 'المفضلة', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                }),
                _buildListTile(Icons.location_on_outlined, 'عناوين غرسة', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressesScreen(),
                    ),
                  );
                }),

                const Divider(),

                // Admin Section (Protected in real app, accessible here for demo)
                _buildListTile(
                  isGuest ? Icons.login : Icons.logout,
                  isGuest ? 'تسجيل الدخول' : 'تسجيل الخروج',
                  () {
                    appProvider.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
