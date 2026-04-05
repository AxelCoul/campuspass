import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../services/student_service.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  late Future<StudentMe> _future;
  final TextEditingController _linkCodeController = TextEditingController();
  bool _linking = false;
  bool _requestingPayout = false;

  Future<void> _copyCode(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié !'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareWhatsApp(BuildContext context, String code) async {
    final message =
        'Salut ! Voici mon code PASS CAMPUS : $code\n\n'
        'Inscris-toi avec ce code et on gagne du crédit dans l’app.';

    final url = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    );

    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir WhatsApp'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _future = StudentService.instance.getMe();
  }

  @override
  void dispose() {
    _linkCodeController.dispose();
    super.dispose();
  }

  Future<void> _linkReferralCode() async {
    final code = _linkCodeController.text.trim().toUpperCase();
    if (code.isEmpty || _linking) return;
    setState(() => _linking = true);
    try {
      await StudentService.instance.linkReferralCode(code);
      _linkCodeController.clear();
      if (!mounted) return;
      setState(() {
        _future = StudentService.instance.getMe();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code de parrainage lié avec succès.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  Future<void> _requestPayout() async {
    if (_requestingPayout) return;
    setState(() => _requestingPayout = true);
    try {
      await StudentService.instance.requestReferralPayout();
      if (!mounted) return;
      setState(() {
        _future = StudentService.instance.getMe();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _requestingPayout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parrainage'),
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
                'Impossible de charger les infos de parrainage.',
                style: AppTextStyles.body(context),
              ),
            );
          }

          final me = snapshot.data!;
          final code = me.referralCode ?? 'PASS${me.hashCode}';
          final balance = me.referralBalance;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite tes amis',
                  style: AppTextStyles.h1(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Partage ton code PASS CAMPUS. À chaque ami qui s’abonne, vous gagnez tous les deux du crédit à utiliser dans l’app.',
                  style: AppTextStyles.body(context),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ton code de parrainage',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          code,
                          style: AppTextStyles.h2(context).copyWith(
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                          TextButton.icon(
                            onPressed: () => _copyCode(context, code),
                            icon: const Icon(Icons.copy_outlined),
                            label: const Text('Copier'),
                          ),
                          const SizedBox(width: 6),
                          TextButton.icon(
                            onPressed: () => _shareWhatsApp(context, code),
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('WhatsApp'),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Solde parrainage',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.currencyCfa(balance.toDouble()),
                  style: AppTextStyles.h2(context).copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requestingPayout ? null : _requestPayout,
                    child: _requestingPayout
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Demander un retrait'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Demande de retrait possible 2 fois par mois. Chaque filleul rémunère une seule fois.',
                  style: AppTextStyles.bodySecondary(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total de filleuls : ${(me.referralsCount ?? 0)}',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ajouter un code de parrainage',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _linkCodeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'PASS1234',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _linking ? null : _linkReferralCode,
                      child: _linking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Lier'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu peux lier un code une seule fois. Le bonus est accordé si le code était lié avant un abonnement du filleul (pas forcément le premier).',
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

