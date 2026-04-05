import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/staff_member.dart';
import '../services/staff_service.dart';
import '../services/auth_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<StaffMember> _team = [];
  bool _loading = true;
  String? _error;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'STAFF';
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await StaffService.instance.getTeam();
      if (!mounted) return;
      setState(() {
        _team = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _createStaff() async {
    if (_creating) return;
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prénom, nom, email et mot de passe sont obligatoires.')),
      );
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      await StaffService.instance.createStaff(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        merchantRole: _selectedRole,
      );
      if (!mounted) return;
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _passwordCtrl.clear();
      _selectedRole = 'STAFF';
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membre ajouté.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _creating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    final merchantRole = user?.merchantRole;

    final canManage =
        merchantRole == null || merchantRole == 'OWNER'; // par défaut OWNER gère l’équipe

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personnel'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],
            if (canManage)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inviter un membre',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(labelText: 'Nom'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Téléphone (optionnel)'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(labelText: 'Mot de passe provisoire'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Rôle'),
                        items: const [
                          DropdownMenuItem(
                            value: 'STAFF',
                            child: Text('Staff (scan & encaissement)'),
                          ),
                          DropdownMenuItem(
                            value: 'MANAGER',
                            child: Text('Manager (offres + stats)'),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedRole = v ?? 'STAFF';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _creating ? null : _createStaff,
                          child: Text(_creating ? 'Création...' : 'Ajouter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Équipe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (_loading && _team.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_team.isEmpty)
              const Text(
                'Aucun membre pour l’instant.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              )
            else
              ..._team.map(
                (m) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(m.displayName),
                    subtitle: Text(
                      [
                        m.email,
                        if (m.merchantRole != null) 'Rôle: ${m.merchantRole}',
                      ].where((e) => (e ?? '').isNotEmpty).join(' · '),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
