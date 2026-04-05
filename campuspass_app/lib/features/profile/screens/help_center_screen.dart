import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre d’aide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Besoin d’aide ?',
              style: AppTextStyles.h1(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour toute question sur PASS CAMPUS, tu peux :\n\n'
              '- Consulter la FAQ (à venir)\n'
              '- Écrire à notre support : support@pass-campus.app\n'
              '- Parler à ton BDE ou à l’équipe sur le campus',
              style: AppTextStyles.body(context),
            ),
          ],
        ),
      ),
    );
  }
}

