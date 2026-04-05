import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'merchant_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;

  Future<void> _logout() async {
    setState(() => _loading = true);
    await AuthService.instance.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    final merchantId = AuthService.instance.merchantId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compte',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text('Email: ${user?.email ?? "-"}'),
                    Text('Commerce ID: ${merchantId ?? "-"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (merchantId != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('Profil du commerce'),
                  subtitle: const Text('Adresse, position, horaires d\'ouverture'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MerchantProfileScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Statistiques'),
              onTap: () => context.push('/analytics'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              onTap: () => context.push('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Support'),
              onTap: () => context.push('/support'),
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Publicités'),
              onTap: () => context.push('/ads'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () => context.push('/notifications'),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Personnel'),
              onTap: () => context.push('/staff'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _logout,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(_loading ? 'Déconnexion...' : 'Déconnexion'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
