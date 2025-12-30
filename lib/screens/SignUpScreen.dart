import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:connect_pharma/screens/User/UserScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _role;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) _role = arg;
  }

  void _showMsg(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _role == null) {
      if (_role == null) _showMsg('Please select a role from previous screen.');
      return;
    }
    setState(() => _loading = true);
    try {
      await authService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _role!,
        displayName: _nameCtrl.text.trim(),
      );
      Navigator.pushReplacement(
        context,
       MaterialPageRoute(builder: (_) => const UserScreen()),
      );
    } catch (e) {
      _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = _role ?? 'No role';
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Signing up as: $roleLabel'),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v ?? '').isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v ?? '').contains('@') ? null : 'Enter valid email',
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v ?? '').length >= 6 ? null : 'Min 6 chars',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Create account'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}