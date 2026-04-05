import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/coupon_service.dart';
import '../utils/coupon_payload.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _manualController = TextEditingController();
  MobileScannerController? _cameraCtrl;

  bool _busy = false;

  static bool get _useCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    if (_useCamera) {
      _cameraCtrl = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    }
  }

  @override
  void dispose() {
    _manualController.dispose();
    _cameraCtrl?.dispose();
    super.dispose();
  }

  String _messageFromError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final m = data['message'] ?? data['error'];
        if (m != null) return m.toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return e.message ?? 'Erreur réseau';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _validateAndNavigate(String raw) async {
    if (_busy) return;
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun commerce associé.')),
        );
      }
      return;
    }

    final code = normalizeCouponPayload(raw);
    if (code.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code vide ou illisible.')),
        );
      }
      return;
    }

    setState(() => _busy = true);

    try {
      final coupon =
          await CouponService.instance.validate(code, merchantId);
      if (!mounted) return;
      await context.push('/coupon-validation', extra: coupon);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_messageFromError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    _validateAndNavigate(raw);
  }

  void _submitManual() {
    _validateAndNavigate(_manualController.text);
  }

  @override
  Widget build(BuildContext context) {
    final camera = _cameraCtrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scanner'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        actions: [
          if (camera != null)
            IconButton(
              tooltip: 'Lampe',
              onPressed:
                  _busy ? null : () => camera.toggleTorch(),
              icon: const Icon(Icons.flashlight_on_outlined),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (camera != null) ...[
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: camera,
                      onDetect: _onDetect,
                    ),
                    CustomPaint(
                      painter: _ScannerOverlayPainter(
                        borderColor: AppColors.primary,
                      ),
                      child: const SizedBox.expand(),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            'Cadre le QR du coupon',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              flex: 2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 72,
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        kIsWeb
                            ? 'Sur le web, saisis le code du coupon manuellement.'
                            : 'Caméra indisponible ici. Saisis le code sous le QR.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Expanded(
            flex: camera != null ? 4 : 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Saisie manuelle',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code affiché sous le QR (ex. CP-…).',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _manualController,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      hintText: 'Code coupon',
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.tag,
                        color: AppColors.primary,
                      ),
                    ),
                    onSubmitted: (_) => _submitManual(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _submitManual,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_busy)
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.check_circle_outline, size: 22),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _busy ? 'Validation…' : 'Valider le coupon',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cadre de visée au centre (zone “safe” pour le QR).
class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cutOut = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.42),
        width: size.width * 0.72,
        height: size.width * 0.72,
      ),
      const Radius.circular(16),
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(cutOut);
    final mask = Path.combine(
      PathOperation.difference,
      overlayPath,
      holePath,
    );

    canvas.drawPath(
      mask,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(cutOut, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
