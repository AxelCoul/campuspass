import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../services/student_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final me = await StudentService.instance.getMe();
      if (!mounted) return;
      setState(() {
        _firstNameController.text = (me.firstName ?? '').trim();
        _emailController.text = (me.email ?? '').trim();
        _phoneController.text = (me.phoneNumber ?? '').trim();
        _cityController.text = (me.city ?? '').trim();
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de charger le profil.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    try {
      setState(() => _savingProfile = true);
      await StudentService.instance.updateProfile(
        firstName: _firstNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis a jour.')),
      );
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (!mounted) return;
      final respData = e.response?.data;
      final msg = (respData is Map && respData['message'] != null)
          ? respData['message'].toString()
          : 'Echec de la mise a jour du profil.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Echec de la mise a jour du profil.')),
      );
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    try {
      setState(() => _savingPassword = true);
      await StudentService.instance.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifie.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final respData = e.response?.data;
      final msg = (respData is Map && respData['message'] != null)
          ? respData['message'].toString()
          : 'Echec de la modification du mot de passe.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Echec de la modification du mot de passe.')),
      );
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations', style: AppTextStyles.h2(context)),
                  const SizedBox(height: 10),
                  Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          enabled: !_savingProfile,
                          decoration: const InputDecoration(
                            labelText: 'Prenom',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Prenom requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_savingProfile,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Email requis';
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          enabled: !_savingProfile,
                          decoration: const InputDecoration(
                            labelText: 'Numero',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cityController,
                          enabled: !_savingProfile,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _savingProfile ? null : _saveProfile,
                            child: Text(_savingProfile ? 'Enregistrement...' : 'Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Mot de passe', style: AppTextStyles.h2(context)),
                  const SizedBox(height: 10),
                  Form(
                    key: _passwordFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          enabled: !_savingPassword,
                          decoration: const InputDecoration(
                            labelText: 'Mot de passe actuel',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Mot de passe actuel requis'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true,
                          enabled: !_savingPassword,
                          decoration: const InputDecoration(
                            labelText: 'Nouveau mot de passe',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Nouveau mot de passe requis';
                            if (v.length < 6) return 'Minimum 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _savingPassword ? null : _changePassword,
                            child: Text(
                              _savingPassword
                                  ? 'Modification...'
                                  : 'Modifier le mot de passe',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
