import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/feature_flags_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _redirected = false;
  Timer? _safetyTimer;
  Timer? _shortDelayTimer;
  Completer<void>? _shortDelayCompleter;
  Timer? _authInitTimeoutTimer;
  bool _disposed = false;

  void _navigate(String route) {
    if (_redirected) return;
    _redirected = true;
    context.go(route);
  }

  @override
  void dispose() {
    _disposed = true;
    _safetyTimer?.cancel();
    _shortDelayTimer?.cancel();
    _authInitTimeoutTimer?.cancel();

    // Libérer les `await` potentiellement en cours lors des tests.
    if (_shortDelayCompleter != null && !_shortDelayCompleter!.isCompleted) {
      _shortDelayCompleter!.complete();
    }
    super.dispose();
  }

  bool get _active => !_disposed && mounted && !_redirected;

  Future<void> _cancelableDelay(Duration duration) {
    _shortDelayTimer?.cancel();
    if (_shortDelayCompleter != null && !_shortDelayCompleter!.isCompleted) {
      _shortDelayCompleter!.complete();
    }

    _shortDelayCompleter = Completer<void>();
    _shortDelayTimer = Timer(duration, () {
      if (_shortDelayCompleter != null && !_shortDelayCompleter!.isCompleted) {
        _shortDelayCompleter!.complete();
      }
    });
    return _shortDelayCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    _init();
    // Filet de sécurité : après 8 s, forcer la redirection
    _safetyTimer = Timer(const Duration(seconds: 8), () {
      if (!_active) return;
      _navigate('/login');
    });
  }

  Future<void> _init() async {
    ApiClient.instance.init();
    try {
      final timeoutCompleter = Completer<void>();
      _authInitTimeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!timeoutCompleter.isCompleted) timeoutCompleter.complete();
      });

      // Attend soit l'initialisation, soit le timeout (sans laisser de Timer en cours).
      await Future.any([
        AuthService.instance.init(),
        timeoutCompleter.future,
      ]);
    } catch (_) {}

    _authInitTimeoutTimer?.cancel();
    _authInitTimeoutTimer = null;

    if (!mounted || _redirected) return;
    await _cancelableDelay(const Duration(milliseconds: 500));
    if (!mounted || _redirected) return;
    final loggedIn =
        AuthService.instance.isLoggedIn && AuthService.instance.merchantId != null;
    if (loggedIn) {
      try {
        await FeatureFlagsService.instance.refresh();
      } catch (_) {}
    }
    if (!mounted || _redirected) return;
    final goLogin = !AuthService.instance.isLoggedIn || AuthService.instance.merchantId == null;
    final route = goLogin ? '/login' : '/';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _redirected) return;
      _navigate(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PASS CAMPUS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Merchant',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
