import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../services/student_service.dart';
import '../../../services/upload_service.dart';
import '../../../services/universities_service.dart';

class StudentVerificationScreen extends StatefulWidget {
  const StudentVerificationScreen({super.key});

  @override
  State<StudentVerificationScreen> createState() => _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  String _documentType = 'STUDENT_CARD';
  File? _selectedFile;
  bool _loading = false;
  bool _universitiesLoading = true;
  List<University> _universities = [];
  String _universityText = '';
  late Future<StudentMe> _meFuture;

  @override
  void initState() {
    super.initState();
    _meFuture = StudentService.instance.getMe();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final list = await UniversitiesService.instance.getActive();
      if (!mounted) return;
      setState(() {
        _universities = list;
        _universitiesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _universities = [];
        _universitiesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification étudiante')),
      body: FutureBuilder<StudentMe>(
        future: _meFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final me = snapshot.data;
          if (me == null) {
            return Center(
              child: Text(
                'Impossible de charger tes infos. Réessaie.',
                style: AppTextStyles.bodySecondary(context),
              ),
            );
          }

          final status = me.studentVerificationStatus.toUpperCase();
          final isApproved = me.studentVerified || status == 'APPROVED';
          final isPending = status == 'PENDING' && !me.studentVerified;

          if (isApproved) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document validé', style: AppTextStyles.h2(context)),
                  const SizedBox(height: 8),
                  Text(
                    'Tu peux t’abonner maintenant.',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.arrow_back_outlined),
                      label: const Text('Retour'),
                    ),
                  ),
                ],
              ),
            );
          }

          if (isPending) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demande en cours', style: AppTextStyles.h2(context)),
                  const SizedBox(height: 8),
                  Text(
                    'Un admin examine ta pièce justificative. Reviens après quelques minutes.',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.refresh_outlined),
                      label: const Text('Retour'),
                    ),
                  ),
                ],
              ),
            );
          }

          // Si rejeté (ou statut encore NONE), on affiche le formulaire.
          final isRejected = status == 'REJECTED' && !me.studentVerified;
          return _buildVerificationForm(
            rejectionReason: isRejected ? me.studentVerificationRejectionReason : null,
          );
        },
      ),
    );
  }

  Widget _buildVerificationForm({String? rejectionReason}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rejectionReason != null && rejectionReason.trim().isNotEmpty) ...[
              Text(
                'Demande rejetée',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 8),
              Text(
                rejectionReason.trim(),
                style: AppTextStyles.bodySecondary(context),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Soumets ta pièce pour validation admin',
              style: AppTextStyles.h2(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu peux t’abonner après validation de ta demande.',
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _documentType,
              decoration: const InputDecoration(
                labelText: 'Type de document',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'STUDENT_CARD',
                  child: Text('Carte étudiante'),
                ),
                DropdownMenuItem(
                  value: 'ENROLLMENT_CERTIFICATE',
                  child: Text('Certificat de scolarité'),
                ),
              ],
              onChanged: _loading
                  ? null
                  : (v) {
                      if (v != null) setState(() => _documentType = v);
                    },
            ),
            const SizedBox(height: 12),
            _universitiesLoading
                ? TextFormField(
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'Université',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _universityText = v,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Université requise' : null,
                  )
                : Autocomplete<University>(
                    displayStringForOption: (u) {
                      final code = (u.code ?? '').trim();
                      if (code.isEmpty) return u.name;
                      return '${u.name} (${code})';
                    },
                    optionsBuilder: (TextEditingValue value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.isEmpty) return const Iterable<University>.empty();

                      final matches = _universities.where((u) {
                        final nameMatch = u.name.toLowerCase().contains(query);
                        final code = (u.code ?? '').trim().toLowerCase();
                        final codeMatch = code.isNotEmpty && code.contains(query);
                        return nameMatch || codeMatch;
                      }).toList();

                      // On limite le nombre de suggestions pour éviter une grosse liste.
                      return matches.take(8);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final list = options.toList();
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final u = list[index];
                                final subtitleParts = <String>[];
                                if (u.code != null && u.code!.trim().isNotEmpty) {
                                  subtitleParts.add(u.code!.trim());
                                }
                                if (u.city != null && u.city!.trim().isNotEmpty) {
                                  subtitleParts.add(u.city!.trim());
                                }
                                if (u.country != null && u.country!.trim().isNotEmpty) {
                                  subtitleParts.add(u.country!.trim());
                                }
                                final subtitle = subtitleParts.join(' · ');

                                return ListTile(
                                  title: Text(u.name),
                                  subtitle: subtitle.isEmpty ? null : Text(subtitle),
                                  onTap: () => onSelected(u),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        enabled: !_loading,
                        decoration: const InputDecoration(
                          labelText: 'Université',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _universityText = v,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Université requise' : null,
                        onFieldSubmitted: (_) => onFieldSubmitted(),
                      );
                    },
                  ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNumberController,
              enabled: !_loading,
              decoration: const InputDecoration(
                labelText: 'Matricule / numéro carte',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Matricule requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              enabled: !_loading,
              decoration: const InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryController,
              enabled: !_loading,
              decoration: const InputDecoration(
                labelText: 'Pays',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loading ? null : _pickImage,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(
                _selectedFile == null ? 'Choisir la pièce' : 'Changer la pièce',
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                _selectedFile!.path.split(RegExp(r'[/\\]')).last,
                style: AppTextStyles.caption(context),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading ? 'Envoi...' : 'Soumettre la demande'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _selectedFile = File(picked.path));
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (!_formKey.currentState!.validate()) return;
    final file = _selectedFile;
    if (file == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ajoute une pièce justificative.')),
      );
      return;
    }
    try {
      setState(() => _loading = true);
      final url = await UploadService.instance.uploadStudentDocument(file);
      await StudentService.instance.submitVerification(
        verificationDocumentType: _documentType,
        studentCardNumber: _cardNumberController.text.trim(),
        studentCardImage: url,
        university: _universityText.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Demande envoyée. Un admin va valider ton document.')),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Échec envoi vérification: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
