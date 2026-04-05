import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';
import '../../shared_widgets/cards/user_summary_card.dart';
import '../../shared_widgets/layout/section_header.dart';
import '../../shared_widgets/cards/saving_tile.dart';
import '../auth/login_screen.dart';
import '../rewards/rewards_screen.dart';

class EconomyScreen extends StatefulWidget {
  const EconomyScreen({super.key});

  @override
  State<EconomyScreen> createState() => _EconomyScreenState();
}

class _EconomyScreenState extends State<EconomyScreen> {
  late Future<StudentMeAndSavings> _future;

  @override
  void initState() {
    super.initState();
    _future = StudentService.instance.getMeWithSavings();
  }

  @override
  Widget build(BuildContext context) {
    // Mode invité : afficher un écran dédié plutôt que d'appeler l'API.
    if (!AuthService.instance.isLoggedIn) {
      return _GuestEconomyPlaceholder();
    }
    return FutureBuilder<StudentMeAndSavings>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de charger tes économies.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _future = StudentService.instance.getMeWithSavings();
                    });
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final me = data.me;
        final savings = data.savings;

        final String displayName;
        if (me.firstName != null && me.firstName!.trim().isNotEmpty) {
          displayName = me.firstName!.trim();
        } else if (me.university != null &&
            me.university!.trim().isNotEmpty) {
          displayName = me.university!.trim();
        } else {
          displayName = 'toi';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserSummaryCard(
                userName: displayName,
                totalSavingsLabel: AppFormatters.currencyCfa(me.totalSavings),
                pointsLabel: '${me.points} points',
                onViewRewards: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RewardsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const SectionHeader(
                title: 'Tes économies ce mois-ci',
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé rapide',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu as économisé au total '
                      '${AppFormatters.currencyCfa(savings.totalSaved)} '
                      'grâce au PASS CAMPUS.',
                      style: AppTextStyles.body(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solde parrainage : ${AppFormatters.currencyCfa(me.referralBalance)}',
                      style: AppTextStyles.body(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(
                title: 'Historique des économies',
              ),
              const SizedBox(height: 8),
              if (savings.history.isEmpty)
                Text(
                  'Tu n\'as pas encore utilisé d\'offres.',
                  style: AppTextStyles.bodySecondary(context),
                )
              else
                Column(
                  children: savings.history.map((entry) {
                    final title = entry.merchantName.isNotEmpty
                        ? entry.merchantName
                        : entry.offerTitle;
                    final subtitle =
                        '${AppFormatters.currencyCfa(entry.savedAmount)} économisés';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SavingTile(
                        title: title,
                        subtitle: subtitle,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GuestEconomyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Connecte-toi pour voir tes économies',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crée un compte étudiant ou connecte-toi pour suivre combien tu as économisé grâce au PASS CAMPUS.',
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Se connecter / Créer un compte'),
            ),
          ),
        ],
      ),
    );
  }
}

