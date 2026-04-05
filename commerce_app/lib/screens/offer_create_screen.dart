import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/offer_service.dart';
import '../services/upload_service.dart';

enum OfferType { percentage, fixedPrice, category, fullStore }

class OfferCreateScreen extends StatefulWidget {
  const OfferCreateScreen({super.key});

  @override
  State<OfferCreateScreen> createState() => _OfferCreateScreenState();
}

class _OfferCreateScreenState extends State<OfferCreateScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _maxCouponsController = TextEditingController(text: '0');

  OfferType _offerType = OfferType.percentage;
  bool _loading = false;
  String? _error;
  File? _pickedImage;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _originalPriceController.dispose();
    _discountPriceController.dispose();
    _discountPercentController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _maxCouponsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null || !mounted) return;
    setState(() {
      _pickedImage = File(xfile.path);
      _error = null;
    });
    try {
      final url = await UploadService.instance.uploadOfferImage(_pickedImage!);
      if (mounted) setState(() => _uploadedImageUrl = url);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur upload: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _uploadedImageUrl = null;
      _imageUrlController.clear();
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? (DateTime.tryParse(_startDateController.text) ?? DateTime.now())
        : (DateTime.tryParse(_endDateController.text) ?? DateTime.now().add(const Duration(days: 30)));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final str = DateFormat('yyyy-MM-dd').format(date);
    if (isStart) {
      _startDateController.text = str;
    } else {
      _endDateController.text = str;
    }
  }

  Future<void> _submit() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) {
      setState(() => _error = 'Commerce non associé');
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Titre obligatoire');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final originalPrice = double.tryParse(_originalPriceController.text.replaceAll(',', '.'));
      final discountPrice = double.tryParse(_discountPriceController.text.replaceAll(',', '.'));
      final discountPercent = double.tryParse(_discountPercentController.text.replaceAll(',', '.'));
      final maxCoupons = int.tryParse(_maxCouponsController.text) ?? 0;

      final imageUrl = _uploadedImageUrl ?? (_imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim());
      final startStr = _startDateController.text.trim();
      final endStr = _endDateController.text.trim();

      final body = <String, dynamic>{
        'merchantId': merchantId,
        'title': title,
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'imageUrl': imageUrl,
        'startDate': startStr.isEmpty ? null : startStr,
        'endDate': endStr.isEmpty ? null : endStr,
        'maxCoupons': maxCoupons,
      };

      switch (_offerType) {
        case OfferType.percentage:
          body['discountPercentage'] = discountPercent ?? 0;
          break;
        case OfferType.fixedPrice:
          if (originalPrice != null) body['originalPrice'] = originalPrice;
          if (discountPrice != null) body['finalPrice'] = discountPrice;
          if (originalPrice != null && discountPrice != null && originalPrice > discountPrice) {
            body['discountAmount'] = originalPrice - discountPrice;
          }
          break;
        case OfferType.category:
        case OfferType.fullStore:
          body['discountPercentage'] = discountPercent ?? 0;
          break;
      }

      await OfferService.instance.create(body);
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle offre'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'offre *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const Text('Image de l\'offre', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_pickedImage != null || _uploadedImageUrl != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, height: 160, width: double.infinity, fit: BoxFit.cover)
                        : _uploadedImageUrl != null
                            ? Image.network(_uploadedImageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder())
                            : _imagePlaceholder(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearImage,
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                ],
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _loading ? null : _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choisir une image dans la galerie'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Ou coller une URL d\'image',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
            const SizedBox(height: 16),
            const Text('Type d\'offre', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<OfferType>(
              value: _offerType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: OfferType.percentage, child: Text('Réduction en % (ex: -20%)')),
                DropdownMenuItem(value: OfferType.fixedPrice, child: Text('Prix fixe (avant / après en FCFA)')),
                DropdownMenuItem(value: OfferType.category, child: Text('Réduction sur une catégorie')),
                DropdownMenuItem(value: OfferType.fullStore, child: Text('Réduction sur tout le magasin')),
              ],
              onChanged: (v) => setState(() => _offerType = v ?? OfferType.percentage),
            ),
            const SizedBox(height: 16),
            if (_offerType == OfferType.fixedPrice) ...[
              TextField(
                controller: _originalPriceController,
                decoration: InputDecoration(
                  labelText: 'Prix normal ($kCurrencySymbol)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _discountPriceController,
                decoration: InputDecoration(
                  labelText: 'Prix promo ($kCurrencySymbol)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ] else ...[
              TextField(
                controller: _discountPercentController,
                decoration: const InputDecoration(
                  labelText: 'Réduction (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date début',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(true),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _endDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date fin',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxCouponsController,
              decoration: const InputDecoration(
                labelText: 'Nombre max d\'utilisations (0 = illimité)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
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
                  : const Text('Publier l\'offre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      color: AppColors.textMuted.withValues(alpha: 0.15),
      child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.textMuted)),
    );
  }
}
