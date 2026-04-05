import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/api_constants.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';

import 'package:dio/dio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await AuthService.instance.init();
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (AuthService.instance.isLoggedIn) {
      // Vérifie que le token est encore valide.
      // Si le backend renvoie 401, on force un logout et on redirige vers Login.
      try {
        await StudentService.instance.getMe();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 401) {
          await AuthService.instance.logout();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        } else {
          // Erreur autre que 401 : on laisse l'utilisateur aller sur Home,
          // le contenu affichera un message d'erreur si besoin.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/pass_campus_logo.png',
              height: 96,
            ),
            const SizedBox(height: 16),
            Text(
              'PASS CAMPUS',
              style: AppTextStyles.h1(context).copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tes économies étudiantes,\nau bon endroit.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

