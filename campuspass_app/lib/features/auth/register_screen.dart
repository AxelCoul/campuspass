import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, this.onGoToLogin, this.onRegistered});

  final VoidCallback? onGoToLogin;
  final VoidCallback? onRegistered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer ton compte étudiant',
                style: AppTextStyles.h1(context),
              ),
              const SizedBox(height: 4),
              Text(
                'Accède à des réductions exclusives dans ta ville.',
                style: AppTextStyles.bodySecondary(context),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _RegisterForm(
                  onRegistered: onRegistered,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte ?',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      if (onGoToLogin != null) {
                        onGoToLogin!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Se connecter',
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({this.onRegistered});

  final VoidCallback? onRegistered;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  bool _acceptedTerms = false;
  bool _submitting = false;
  String? _error;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _referralCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'Les mots de passe ne correspondent pas.';
      });
      return;
    }
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty || !_acceptedTerms) return;

    final parts = fullName.split(' ');
    final firstName = parts.first;
    final lastName =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.instance.register(
        firstName: firstName,
        lastName: lastName,
        password: _passwordController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        referralCode: _referralCodeController.text.trim(),
      );
      if (widget.onRegistered != null) {
        widget.onRegistered!.call();
      } else if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nom complet', style: AppTextStyles.caption(context)),
          const SizedBox(height: 2),
          TextField(
            controller: _fullNameController,
            decoration: InputDecoration(
              hintText: 'Axel Ouédraogo',
              hintStyle: AppTextStyles.bodySecondary(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Text('Numéro de téléphone', style: AppTextStyles.caption(context)),
          const SizedBox(height: 2),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '07 XX XX XX',
              hintStyle: AppTextStyles.bodySecondary(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Text('Mot de passe', style: AppTextStyles.caption(context)),
          const SizedBox(height: 2),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTextStyles.bodySecondary(context),
              suffixIcon: const Icon(Icons.visibility_off_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Text('Confirmer le mot de passe', style: AppTextStyles.caption(context)),
          const SizedBox(height: 2),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTextStyles.bodySecondary(context),
              suffixIcon: const Icon(Icons.visibility_off_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Text('Code de parrainage (optionnel)', style: AppTextStyles.caption(context)),
          const SizedBox(height: 2),
          TextField(
            controller: _referralCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'PASS1234',
              hintStyle: AppTextStyles.bodySecondary(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: (v) {
                  setState(() {
                    _acceptedTerms = v ?? false;
                  });
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.caption(context),
                    children: [
                      const TextSpan(text: 'J’accepte les '),
                      TextSpan(
                        text: 'Conditions générales',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'Politique de confidentialité',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 2),
            Text(
              _error!,
              style: AppTextStyles.caption(context)
                  .copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _acceptedTerms ? AppColors.primary : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _acceptedTerms && !_submitting ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Créer mon compte',
                      style: AppTextStyles.buttonPrimary(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


