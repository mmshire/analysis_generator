import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _phoneCtrl  = TextEditingController(text: '+252 ');
  bool  _loading    = false;

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().sendOtp(_phoneCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.otpVerify,
        arguments: _phoneCtrl.text.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text('🍽️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 24),
                const Text('Enter your\nphone number',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2)),
                const SizedBox(height: 8),
                const Text('We will send a 6-digit verification code',
                  style: TextStyle(color: AppColors.textMid, fontSize: 15)),
                const SizedBox(height: 36),

                TextFormField(
                  controller:   _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, letterSpacing: 1),
                  decoration: const InputDecoration(
                    labelText:   'Phone number',
                    prefixIcon:  Icon(Icons.phone_outlined),
                    hintText:    '+252 63 000 0000',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 8) return 'Please enter a valid phone number';
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Send Code'),
                    ),

                const Spacer(),
                Center(
                  child: Text('By continuing you agree to our Terms of Service',
                    style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
