import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onGoToRegister,
    this.onLoggedIn,
    this.onContinueAsGuest,
  });

  final VoidCallback? onGoToRegister;
  final VoidCallback? onLoggedIn;
  final VoidCallback? onContinueAsGuest;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _submitting = false;
  String? _error;

  Future<void> _handleSubmit(String phoneNumber, String password) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.instance.login(phoneNumber, password);
      if (widget.onLoggedIn != null) {
        widget.onLoggedIn!.call();
      } else if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (widget.onContinueAsGuest != null) {
                widget.onContinueAsGuest!.call();
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
            child: Text(
              'Continuer sans compte',
              style: AppTextStyles.bodySecondary(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _Logo(),
              const SizedBox(height: 16),
              Text(
                'Bienvenue sur PASS CAMPUS',
                style: AppTextStyles.h1(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connecte-toi pour profiter de tes réductions étudiantes.',
                style: AppTextStyles.bodySecondary(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _LoginForm(
                submitting: _submitting,
                error: _error,
                onSubmit: _handleSubmit,
              ),
              const SizedBox(height: 16),
              const _SocialSection(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore de compte ?',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      if (widget.onGoToRegister != null) {
                        widget.onGoToRegister!.call();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              onRegistered: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                  (_) => false,
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Créer un compte',
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

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          Icons.confirmation_number_outlined,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.submitting,
    required this.error,
    required this.onSubmit,
  });

  final bool submitting;
  final String? error;
  final Future<void> Function(String email, String password) onSubmit;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Numéro de téléphone',
            style: AppTextStyles.caption(context),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '07 XX XX XX',
              hintStyle: AppTextStyles.bodySecondary(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mot de passe',
            style: AppTextStyles.caption(context),
          ),
          const SizedBox(height: 4),
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
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Mot de passe oublié ?',
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.error!,
              style: AppTextStyles.caption(context)
                  .copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: widget.submitting
                  ? null
                  : () {
                      widget.onSubmit(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
              child: widget.submitting
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
                      'Se connecter',
                      style: AppTextStyles.buttonPrimary(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ou',
              style: AppTextStyles.caption(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Continuer avec Google',
                  style: AppTextStyles.body(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

