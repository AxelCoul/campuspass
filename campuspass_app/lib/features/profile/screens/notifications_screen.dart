import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool offers = true;
  bool news = true;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choisis les notifications que tu souhaites recevoir.',
            style: AppTextStyles.body(context),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Offres et promotions'),
            subtitle: const Text('Être prévenu des nouvelles offres PASS CAMPUS'),
            value: offers,
            onChanged: (v) => setState(() => offers = v),
          ),
          SwitchListTile(
            title: const Text('Nouveaux commerces'),
            subtitle: const Text('Être informé quand un nouveau partenaire arrive'),
            value: news,
            onChanged: (v) => setState(() => news = v),
          ),
          SwitchListTile(
            title: const Text('Rappels'),
            subtitle: const Text('Rappels pour tes abonnements et tes économies'),
            value: reminders,
            onChanged: (v) => setState(() => reminders = v),
          ),
        ],
      ),
    );
  }
}

