import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = AppSettings.instance.themeMode == ThemeMode.dark;
  String language = AppSettings.instance.languageCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Préférences',
            style: AppTextStyles.h1(context),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: darkMode,
            onChanged: (v) {
              setState(() {
                darkMode = v;
              });
              AppSettings.instance
                  .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Langue de l’application',
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButton<String>(
            value: language,
            items: const [
              DropdownMenuItem(value: 'fr', child: Text('Français')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                language = v;
              });
              AppSettings.instance.setLanguageCode(v);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'D’autres langues seront disponibles dans une prochaine version.',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Ces paramètres sont pour l’instant locaux à ton appareil. La gestion avancée (multi-langues, thème global) pourra être ajoutée plus tard.',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}

