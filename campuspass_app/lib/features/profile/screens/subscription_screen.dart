import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../services/student_service.dart';
import '../../../services/api_client.dart';
import 'package:dio/dio.dart';
import 'student_verification_screen.dart';
import 'payment_webview_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with WidgetsBindingObserver {
  late Future<StudentMe> _future;
  late Future<List<_ActivePlan>> _plansFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _future = StudentService.instance.getMe();
    _plansFuture = _loadActivePlans();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement & paiements'),
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
                'Impossible de charger ton abonnement.',
                style: AppTextStyles.body(context),
              ),
            );
          }

          final me = snapshot.data!;
          final hasSub = me.hasActiveSubscription;
          final planName = me.subscriptionPlanName ?? 'Aucun abonnement actif';
          final canSubscribe = me.studentVerified;
          final verificationStatus = me.studentVerificationStatus.toUpperCase();
          final rejectionReason = me.studentVerificationRejectionReason;

          final disabledReason = canSubscribe ? null : (verificationStatus == 'REJECTED' ? 'Ta demande a été rejetée' : 'Ta vérification n’est pas encore validée');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OnboardingStepsCard(
                  studentVerified: me.studentVerified,
                  hasActiveSubscription: me.hasActiveSubscription,
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ton offre actuelle', style: AppTextStyles.h1(context)),
                        const SizedBox(height: 10),
                        Text(
                          hasSub ? planName : 'Aucun abonnement actif',
                          style: AppTextStyles.body(context),
                        ),
                        if (hasSub && me.subscriptionEndDate != null && me.subscriptionEndDate!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Valable jusqu’au : ${me.subscriptionEndDate}',
                            style: AppTextStyles.bodySecondary(context),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (!canSubscribe)
                          _StudentVerificationBanner(
                            verified: canSubscribe,
                            status: verificationStatus,
                            rejectionReason: rejectionReason,
                            onSubmit: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => const StudentVerificationScreen(),
                                ),
                              );
                              if (changed == true && mounted) {
                                setState(() {
                                  _future = StudentService.instance.getMe();
                                });
                              }
                            },
                          ),
                      ],
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
                          'Forfaits disponibles',
                          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        if (hasSub) ...[
                          Text(
                            'Tu es déjà abonné : un nouvel achat prolongera la date de fin.',
                            style: AppTextStyles.bodySecondary(context),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (disabledReason != null) ...[
                          Text(
                            disabledReason,
                            style: AppTextStyles.bodySecondary(context),
                          ),
                          const SizedBox(height: 12),
                        ],
                        FutureBuilder<List<_ActivePlan>>(
                          future: _plansFuture,
                          builder: (context, plansSnapshot) {
                            if (plansSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: LinearProgressIndicator(),
                              );
                            }
                            if (plansSnapshot.hasError) {
                              return Text(
                                'Erreur lors du chargement des forfaits.',
                                style: AppTextStyles.bodySecondary(context),
                              );
                            }
                            final plans = plansSnapshot.data ?? const [];
                            if (plans.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aucun forfait actif pour le moment.',
                                    style: AppTextStyles.bodySecondary(context),
                                  ),
                                  if (hasSub) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: _loading
                                            ? null
                                            : () {
                                                setState(() {
                                                  _plansFuture = _loadActivePlans();
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Aucun forfait de reabonnement disponible pour le moment.',
                                                    ),
                                                  ),
                                                );
                                              },
                                        child: const Text('Se réabonner'),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }
                            return Column(
                              children: [
                                for (int i = 0; i < plans.length; i++) ...[
                                  _PlanTile(
                                    title: plans[i].name,
                                    subtitle: '${plans[i].effectivePrice.toStringAsFixed(0)} FCFA',
                                    disabled: _loading || !canSubscribe || plans[i].id <= 0,
                                    buttonText: hasSub ? 'Se réabonner' : 'S’abonner',
                                    onPressed: () => _onTapActivate(
                                      context,
                                      planId: plans[i].id,
                                      phoneNumber: me.phoneNumber ?? '00000000',
                                    ),
                                  ),
                                  if (i != plans.length - 1) const SizedBox(height: 8),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!mounted) return;
    setState(() {
      _future = StudentService.instance.getMe();
    });
  }

  Future<void> _startSubscribe(BuildContext context, int planId, String phoneNumber) async {
    try {
      setState(() => _loading = true);
      final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/subscription/subscribe',
        data: {
          'planId': planId,
          'paymentMethod': 'ORANGE_MONEY',
          'phoneNumber': phoneNumber,
        },
      );
      final data = res.data ?? const {};
      final paymentId = data['paymentId'] is num ? (data['paymentId'] as num).toInt() : null;
      final paymentUrl = data['paymentUrl']?.toString();
      if (paymentId != null && paymentUrl != null && paymentUrl.isNotEmpty) {
        if (!context.mounted) return;
        final webviewResult = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PaymentWebviewScreen(paymentUrl: paymentUrl),
          ),
        );
        if (mounted) {
          final success = await _checkPaymentStatusWithRetry(
            context,
            paymentId,
            attempts: 3,
            delayMs: 2200,
          );
          if (!context.mounted) return;
          if (success) {
            await showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Paiement effectue avec succes'),
                content: const Text('Ton abonnement a ete mis a jour.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (webviewResult == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La page de paiement a rencontre un probleme. Verifie a nouveau dans quelques secondes.'),
              ),
            );
          }
        }
      }
    } on DioException catch (e) {
      if (!context.mounted) return;
      final respData = e.response?.data;
      String? backendMessage =
          (respData is Map && respData['message'] != null) ? respData['message'].toString() : null;
      final providerBody = (respData is Map && respData['providerBody'] != null)
          ? respData['providerBody'].toString()
          : null;
      if (providerBody != null && providerBody.isNotEmpty) {
        backendMessage = backendMessage != null ? '$backendMessage\n$providerBody' : providerBody;
      }
      final msg = backendMessage ??
          (respData != null ? respData.toString() : 'Erreur lors de la simulation d’abonnement.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la simulation d’abonnement.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onTapActivate(
    BuildContext context, {
    required int planId,
    required String phoneNumber,
  }) async {
    await _startSubscribe(context, planId, phoneNumber);
  }

  Future<bool> _checkPaymentStatusWithRetry(
    BuildContext context,
    int paymentId, {
    int attempts = 3,
    int delayMs = 2000,
  }) async {
    for (var i = 0; i < attempts; i++) {
      final success = await _checkPaymentStatus(context, paymentId, silent: i < attempts - 1);
      if (success) return true;
      if (i < attempts - 1) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    return false;
  }

  Future<bool> _checkPaymentStatus(
    BuildContext context,
    int paymentId, {
    bool silent = false,
  }) async {
    try {
      setState(() => _loading = true);
      final res = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/subscription/payment-status/$paymentId',
      );
      final data = res.data ?? const {};
      final success = data['success'] == true;
      if (success) {
        setState(() {
          _future = StudentService.instance.getMe();
        });
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (!context.mounted) return false;
      final respData = e.response?.data;
      String? backendMessage =
          (respData is Map && respData['message'] != null) ? respData['message'].toString() : null;
      final providerBody = (respData is Map && respData['providerBody'] != null)
          ? respData['providerBody'].toString()
          : null;
      if (providerBody != null && providerBody.isNotEmpty) {
        backendMessage = backendMessage != null ? '$backendMessage\n$providerBody' : providerBody;
      }
      final msg = backendMessage ??
          (respData != null ? respData.toString() : 'Impossible de vérifier le paiement.');
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<List<_ActivePlan>> _loadActivePlans() async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>('/plans');
    final data = res.data ?? const [];
    return data.map((e) => _ActivePlan.fromJson(e as Map<String, dynamic>)).toList();
  }

}

class _PlanTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool disabled;
  final String buttonText;
  final VoidCallback onPressed;

  const _PlanTile({
    required this.title,
    required this.subtitle,
    required this.disabled,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        title: Text(title, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySecondary(context)),
        trailing: ElevatedButton(
          onPressed: disabled ? null : onPressed,
          child: Text(buttonText),
        ),
      ),
    );
  }
}

class _StudentVerificationBanner extends StatelessWidget {
  final bool verified;
  final String status;
  final String? rejectionReason;
  final Future<void> Function()? onSubmit;

  const _StudentVerificationBanner({
    required this.verified,
    required this.status,
    this.rejectionReason,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bg = verified
        ? Colors.green.withValues(alpha: 0.12)
        : Colors.red.withValues(alpha: 0.12);
    final fg = verified ? Colors.green.shade700 : Colors.red.shade700;
    final title = switch (status) {
      'APPROVED' => 'Statut étudiant vérifié',
      'PENDING' => 'Validation en cours',
      'REJECTED' => 'Demande rejetée',
      _ => verified ? 'Statut étudiant vérifié' : 'Statut étudiant non vérifié',
    };
    final desc = switch (status) {
      'APPROVED' => 'Tu peux t’abonner.',
      'PENDING' => 'Ta demande est en cours de traitement par un admin.',
      'REJECTED' => (rejectionReason != null && rejectionReason!.trim().isNotEmpty)
          ? 'Motif: ${rejectionReason!.trim()}'
          : 'Soumets une nouvelle pièce pour réessayer.',
      _ => 'Tu dois verifier ton statut etudiant avant de pouvoir t’abonner.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  desc,
                  style: AppTextStyles.bodySecondary(context).copyWith(color: fg),
                ),
              ),
              if (!verified)
                TextButton(
                  onPressed: onSubmit,
                  child: const Text('Verifier mon statut etudiant'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepsCard extends StatelessWidget {
  const _OnboardingStepsCard({
    required this.studentVerified,
    required this.hasActiveSubscription,
  });

  final bool studentVerified;
  final bool hasActiveSubscription;

  @override
  Widget build(BuildContext context) {
    final step1Done = studentVerified;
    final step2Done = hasActiveSubscription;
    final step3Done = step1Done && step2Done;

    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Etat d’avancement',
              style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _StepRow(
              index: 1,
              label: 'Verification etudiant',
              done: step1Done,
            ),
            const SizedBox(height: 8),
            _StepRow(
              index: 2,
              label: 'Abonnement',
              done: step2Done,
            ),
            const SizedBox(height: 8),
            _StepRow(
              index: 3,
              label: 'Utiliser les offres',
              done: step3Done,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.label,
    required this.done,
  });

  final int index;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final bg = done ? Colors.green.withValues(alpha: 0.14) : Colors.black12;
    final fg = done ? Colors.green.shade700 : Colors.black54;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: done
              ? Icon(Icons.check, size: 14, color: fg)
              : Text(
                  '$index',
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary(context).copyWith(
              color: fg,
              fontWeight: done ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivePlan {
  final int id;
  final String name;
  final double effectivePrice;

  _ActivePlan({
    required this.id,
    required this.name,
    required this.effectivePrice,
  });

  factory _ActivePlan.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? '') ?? -1;
    final price = (json['effectivePrice'] as num?)?.toDouble() ?? 0.0;
    final name = json['name']?.toString() ?? 'Plan';
    return _ActivePlan(id: id, name: name, effectivePrice: price);
  }
}


