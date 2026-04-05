import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../models/merchant.dart';
import '../services/auth_service.dart';
import '../services/merchant_service.dart';
import '../services/upload_service.dart';

class MerchantProfileScreen extends StatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  Merchant? _merchant;
  bool _loading = true;
  bool _saving = false;
  String? _message;
  File? _pickedLogo;
  String? _uploadedLogoUrl;

  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _openingHoursCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _openingHoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) {
      setState(() {
        _loading = false;
        _message = 'Aucun commerce associé à ce compte.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final m = await MerchantService.instance.getById(merchantId);
      if (!mounted) return;
      setState(() {
        _merchant = m;
        _loading = false;
      });
      _uploadedLogoUrl = m.logoUrl;
      _addressCtrl.text = m.address ?? '';
      _cityCtrl.text = m.city ?? '';
      _countryCtrl.text = m.country ?? '';
      _latCtrl.text = m.latitude?.toString() ?? '';
      _lngCtrl.text = m.longitude?.toString() ?? '';
      _openingHoursCtrl.text = m.openingHours ?? '';
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Erreur lors du chargement des informations.';
      });
    }
  }

  Future<void> _save() async {
    if (_merchant == null) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      double? lat;
      double? lng;
      if (_latCtrl.text.trim().isNotEmpty) {
        lat = double.tryParse(_latCtrl.text.trim());
      }
      if (_lngCtrl.text.trim().isNotEmpty) {
        lng = double.tryParse(_lngCtrl.text.trim());
      }

      final updated = await MerchantService.instance.update(_merchant!.id, {
        'name': _merchant!.name,
        'logoUrl': _uploadedLogoUrl ?? _merchant!.logoUrl,
        'address': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        'country': _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
        'latitude': lat,
        'longitude': lng,
        'openingHours': _openingHoursCtrl.text.trim().isEmpty ? null : _openingHoursCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _merchant = updated;
        _saving = false;
        _message = 'Enregistrement réussi.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = 'Erreur lors de l\'enregistrement.';
      });
    }
  }

  Future<void> _pickLogo(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null || !mounted) return;
    setState(() {
      _pickedLogo = File(xfile.path);
      _saving = true;
      _message = null;
    });
    try {
      final url = await UploadService.instance.uploadOfferImage(_pickedLogo!);
      if (!mounted) return;
      setState(() {
        _uploadedLogoUrl = url;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = 'Erreur lors de l\'upload du logo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil du commerce'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_merchant != null) ...[
                    Text(
                      _merchant!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: (_uploadedLogoUrl ?? _merchant!.logoUrl) != null
                              ? NetworkImage(_uploadedLogoUrl ?? _merchant!.logoUrl!)
                              : null,
                          child: (_uploadedLogoUrl ?? _merchant!.logoUrl) == null
                              ? const Icon(Icons.storefront, color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logo du commerce',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: _saving ? null : () => _pickLogo(ImageSource.camera),
                                    icon: const Icon(Icons.photo_camera),
                                    label: const Text('Caméra'),
                                  ),
                                  TextButton.icon(
                                    onPressed: _saving ? null : () => _pickLogo(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Galerie'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Localisation & horaires',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Adresse',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Ville',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _countryCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Pays',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _latCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Latitude',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _lngCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _openingHoursCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Horaires d\'ouverture',
                              hintText: 'Ex: Lun-Dim 08h00 - 22h00',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _saving ? null : _save,
                              child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                            ),
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _message!,
                              style: TextStyle(
                                color: _message == 'Enregistrement réussi.' ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

