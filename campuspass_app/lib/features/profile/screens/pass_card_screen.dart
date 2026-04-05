import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/student_service.dart';

class PassCardScreen extends StatefulWidget {
  const PassCardScreen({super.key});

  @override
  State<PassCardScreen> createState() => _PassCardScreenState();
}

class _PassCardScreenState extends State<PassCardScreen> {
  late Future<StudentMe> _future;

  @override
  void initState() {
    super.initState();
    _future = StudentService.instance.getMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte PASS CAMPUS'),
      ),
      body: FutureBuilder<StudentMe>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Impossible de charger ta carte.',
                style: AppTextStyles.body(context),
              ),
            );
          }

          final me = snapshot.data!;
          final plan = me.subscriptionPlanName ?? 'Aucun abonnement actif';
          final active = me.hasActiveSubscription;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ta carte étudiante',
                  style: AppTextStyles.h1(context),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.deepOrange],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PASS CAMPUS',
                        style: AppTextStyles.h2(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan,
                        style: AppTextStyles.bodySecondary(context).copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        active ? 'Statut : Actif' : 'Statut : Inactif',
                        style: AppTextStyles.body(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tes économies totales',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.currencyCfa(me.totalSavings),
                  style: AppTextStyles.h2(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

