import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/offer.dart';
import '../services/auth_service.dart';
import '../services/offer_service.dart';
import '../services/upload_service.dart';

class OfferEditScreen extends StatefulWidget {
  const OfferEditScreen({super.key, required this.offerId});

  final int offerId;

  @override
  State<OfferEditScreen> createState() => _OfferEditScreenState();
}

class _OfferEditScreenState extends State<OfferEditScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _maxCouponsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  Offer? _offer;
  File? _pickedImage;
  String? _uploadedImageUrl;
  bool _imageCleared = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();
    _maxCouponsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final offer = await OfferService.instance.getById(widget.offerId);
      if (mounted) {
        setState(() {
          _offer = offer;
          _loading = false;
          _titleController.text = offer.title;
          _descController.text = offer.description ?? '';
          _originalPriceController.text = offer.originalPrice?.toString() ?? '';
          _discountController.text = offer.discountPercentage?.toString() ?? '';
          _maxCouponsController.text = offer.maxCoupons?.toString() ?? '0';
          _startDateController.text = offer.startDate ?? '';
          _endDateController.text = offer.endDate ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
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
      if (mounted) setState(() {
        _uploadedImageUrl = url;
        _imageCleared = false;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur upload: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _uploadedImageUrl = null;
      _imageCleared = true;
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
    if (merchantId == null || _offer == null) {
      setState(() => _error = 'Commerce ou offre invalide');
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Titre obligatoire');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final originalPrice = double.tryParse(_originalPriceController.text.replaceAll(',', '.')) ?? 0.0;
      final discount = double.tryParse(_discountController.text.replaceAll(',', '.')) ?? 0.0;
      final maxCoupons = int.tryParse(_maxCouponsController.text) ?? 0;
      await OfferService.instance.update(widget.offerId, {
        'merchantId': merchantId,
        'title': title,
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'originalPrice': originalPrice,
        'discountPercentage': discount,
        'maxCoupons': maxCoupons,
        'imageUrl': _imageCleared ? null : (_uploadedImageUrl ?? _offer?.imageUrl),
        'startDate': _startDateController.text.trim().isEmpty ? null : _startDateController.text.trim(),
        'endDate': _endDateController.text.trim().isEmpty ? null : _endDateController.text.trim(),
      });
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_offer != null ? 'Modifier: ${_offer!.title}' : 'Modifier offre'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _offer == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Réessayer')),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Image de l\'offre', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_pickedImage != null || _uploadedImageUrl != null || (_offer?.imageUrl != null && _offer!.imageUrl!.isNotEmpty)) ...[
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _pickedImage != null
                                  ? Image.file(_pickedImage!, height: 140, width: double.infinity, fit: BoxFit.cover)
                                  : (_uploadedImageUrl ?? _offer?.imageUrl) != null
                                      ? Image.network(resolveImageUrl(_uploadedImageUrl ?? _offer?.imageUrl), height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph())
                                      : _ph(),
                            ),
                            IconButton(icon: const Icon(Icons.close), onPressed: _clearImage, style: IconButton.styleFrom(backgroundColor: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(onPressed: _saving ? null : _pickImage, icon: const Icon(Icons.photo_library), label: const Text('Changer l\'image')),
                      ] else ...[
                        OutlinedButton.icon(onPressed: _saving ? null : _pickImage, icon: const Icon(Icons.photo_library), label: const Text('Choisir une image dans la galerie')),
                      ],
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _originalPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Prix initial ($kCurrencySymbol)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          labelText: 'Réduction (%)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _maxCouponsController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre max de coupons (0 = illimité)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date début',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(true)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date fin',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(false)),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _ph() {
    return Container(
      height: 140,
      color: AppColors.textMuted.withValues(alpha: 0.15),
      child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.textMuted)),
    );
  }
}
