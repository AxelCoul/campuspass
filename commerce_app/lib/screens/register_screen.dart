import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../core/theme/app_colors.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

/// Inscription commerçant : crée un compte MERCHANT + un commerce, puis connecte l'utilisateur.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _merchantNameController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _merchantNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final merchantName = _merchantNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _error = 'Prénom et nom obligatoires');
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = 'Email obligatoire');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Mot de passe : 6 caractères minimum');
      return;
    }
    if (merchantName.isEmpty) {
      setState(() => _error = 'Nom du commerce obligatoire');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': 'MERCHANT',
          'merchantName': merchantName,
        },
      );
      if (!mounted) return;
      // Connexion automatique avec les mêmes identifiants
      await AuthService.instance.login(email, password);
      if (!mounted) return;
      context.go('/');
    } catch (e, _) {
      if (!mounted) return;
      String msg = e.toString().replaceFirst('Exception: ', '');
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null) msg = data['message'].toString();
      } else if (msg.contains('DioException') || msg.contains('connection') || msg.contains('SocketException')) {
        msg = 'Backend injoignable. Vérifiez que le serveur tourne sur le port 8081.';
      }
      setState(() {
        _error = msg;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe * (6 caractères min)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _merchantNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du commerce *',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _register,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Créer mon compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
