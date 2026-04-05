import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifications push'),
            subtitle: const Text('Alertes offres et transactions'),
            value: true,
            onChanged: (v) {},
          ),
          const ListTile(
            title: Text('Langue'),
            subtitle: Text('Français'),
          ),
          const ListTile(
            title: Text('Sécurité'),
            subtitle: Text('Modifier le mot de passe'),
          ),
        ],
      ),
    );
  }
}
