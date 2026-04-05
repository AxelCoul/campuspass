import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';
import '../../shared_widgets/cards/user_summary_card.dart';
import '../../shared_widgets/layout/section_header.dart';
import '../referral/referral_screen.dart';
import '../rewards/rewards_screen.dart';
import '../splash/splash_screen.dart';
import '../auth/login_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/student_verification_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/payment_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<StudentMe> _future;

  @override
  void initState() {
    super.initState();
    _future = StudentService.instance.getMe();
  }

  @override
  Widget build(BuildContext context) {
    // Si invité : afficher un profil "public" minimal, sans appel API.
    if (!AuthService.instance.isLoggedIn) {
      return _GuestProfile();
    }
    return FutureBuilder<StudentMe>(
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
                const Text('Impossible de charger ton profil.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _future = StudentService.instance.getMe();
                    });
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final me = snapshot.data!;
        final String displayName;
        if (me.firstName != null && me.firstName!.trim().isNotEmpty) {
          final first = me.firstName!.trim();
          final last = me.lastName?.trim();
          displayName = (last == null || last.isEmpty) ? first : '$first $last';
        } else if (me.university != null &&
            me.university!.trim().isNotEmpty) {
          displayName = me.university!.trim();
        } else {
          displayName = 'Étudiant PASS CAMPUS';
        }
        final city = me.city ?? 'Ville inconnue';
        final university = me.university ?? 'Université non renseignée';
        final email = me.email ?? AuthService.instance.email ?? '-';
        final phone = me.phoneNumber ?? '-';
        final hasSub = me.hasActiveSubscription;
        final planName = me.subscriptionPlanName ?? 'Plan étudiant';
        final endDate = (me.subscriptionEndDate ?? '').trim();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                    if (!context.mounted) return;
                    if (changed == true) {
                      setState(() {
                        _future = StudentService.instance.getMe();
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.secondary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.h2(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Étudiant · $university',
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              city,
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phone,
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut d’abonnement',
                        style: AppTextStyles.body(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasSub ? 'Actif - $planName' : 'Non abonné',
                        style: AppTextStyles.h2(context),
                      ),
                      if (hasSub && endDate.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Expire le : $endDate',
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen(),
                              ),
                            );
                            if (!context.mounted) return;
                            setState(() {
                              _future = StudentService.instance.getMe();
                            });
                          },
                          child: Text(
                            hasSub ? 'Se réabonner' : 'S’abonner',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'Mon compte',
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.stars_outlined,
                title: 'Points fidelite & cadeaux',
                subtitle: 'Voir mes points et echanger mes recompenses',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RewardsScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.payment_outlined,
                title: 'Abonnement & paiements',
                subtitle: me.studentVerified
                    ? 'Gérer mon offre et mes moyens de paiement'
                    : 'Verification etudiante requise avant abonnement',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen(),
                    ),
                  );
                  if (!context.mounted) return;
                  setState(() {
                    _future = StudentService.instance.getMe();
                  });
                },
              ),
              _ProfileTile(
                icon: Icons.receipt_long_outlined,
                title: 'Historique des paiements',
                subtitle: 'Voir toutes mes transactions',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaymentHistoryScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.verified_user_outlined,
                title: 'Vérification étudiante',
                subtitle: me.studentVerified
                    ? 'Document validé'
                    : (me.studentVerificationStatus.toUpperCase() == 'PENDING'
                        ? 'Demande en cours de traitement'
                        : me.studentVerificationStatus.toUpperCase() == 'REJECTED'
                            ? (me.studentVerificationRejectionReason != null &&
                                    me.studentVerificationRejectionReason!.trim().isNotEmpty)
                                ? 'Rejet : ${me.studentVerificationRejectionReason!.trim()}'
                                : 'Demande rejetée, soumettre à nouveau'
                            : 'Soumettre carte étudiante / certificat'),
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const StudentVerificationScreen(),
                    ),
                  );
                  if (changed == true && context.mounted) {
                    setState(() {
                      _future = StudentService.instance.getMe();
                    });
                  }
                },
              ),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Gérer les alertes et emails',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Aide & préférences',
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.card_giftcard_outlined,
                title: 'Parrainage',
                subtitle: 'Invite tes amis et gagne du crédit',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReferralScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Centre d’aide',
                subtitle: 'FAQ, support, signaler un problème',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: 'Paramètres',
                subtitle: 'Langue, confidentialité',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await AuthService.instance.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Se déconnecter',
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GuestProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserSummaryCard(
            userName: 'Invité',
            totalSavingsLabel: AppFormatters.currencyCfa(0),
            pointsLabel: '0 points',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connecte-toi pour personnaliser ton profil',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crée un compte étudiant pour voir ton abonnement, tes économies, tes points et accéder au parrainage.',
                  style: AppTextStyles.bodySecondary(context),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Se connecter / Créer un compte'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Aide & informations',
          ),
          const SizedBox(height: 8),
          _ProfileTile(
            icon: Icons.help_outline,
            title: 'Centre d’aide',
            subtitle: 'FAQ, support, signaler un problème',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            subtitle: 'Langue, confidentialité',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.caption(context),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          thickness: 0.5,
        ),
      ],
    );
  }
}

