import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/dashboard_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/offers_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _dashboardKey = GlobalKey<State<DashboardScreen>>();
  final _offersKey = GlobalKey<State<OffersScreen>>();
  late final List<Widget> _screens;

  static const _tabs = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard'),
    (icon: Icons.qr_code_scanner, label: 'Scanner'),
    (icon: Icons.local_offer_outlined, label: 'Offres'),
    (icon: Icons.receipt_long_outlined, label: 'Transactions'),
    (icon: Icons.person_outline, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        key: _dashboardKey,
        onSwitchTab: (index) => setState(() => _index = index),
      ),
      const ScannerScreen(),
      OffersScreen(key: _offersKey),
      const TransactionsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.instance.merchantId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Aucun commerce associé à ce compte.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await AuthService.instance.logout();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Déconnexion'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 0) (_dashboardKey.currentState as dynamic)?.load();
          if (i == 2) (_offersKey.currentState as dynamic)?.load();
        },
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
