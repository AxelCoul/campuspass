import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.help_outline, color: AppColors.primary),
                title: const Text('FAQ'),
                subtitle: const Text('Questions fréquentes'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.mail_outline, color: AppColors.primary),
                title: const Text('Nous contacter'),
                subtitle: const Text('support@passcampus.com'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Besoin d\'aide ? Envoyez un message ou consultez la FAQ.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
