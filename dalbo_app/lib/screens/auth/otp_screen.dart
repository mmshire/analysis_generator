import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinCtrl = TextEditingController();
  bool  _loading = false;
  String get _phone => ModalRoute.of(context)!.settings.arguments as String;

  Future<void> _verify(String code) async {
    if (code.length != 6) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().verifyOtp(_phone, code);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
      _pinCtrl.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await context.read<AuthProvider>().sendOtp(_phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() { _pinCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 52, height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Text('Verification code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Builder(builder: (_) => Text(
                'We sent a 6-digit code to $_phone',
                style: const TextStyle(color: AppColors.textMid),
              )),
              const SizedBox(height: 40),

              Center(
                child: Pinput(
                  controller:   _pinCtrl,
                  length:       6,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyWith(
                    decoration: pinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onCompleted: _verify,
                  autofocus: true,
                ),
              ),

              const SizedBox(height: 40),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: () => _verify(_pinCtrl.text),
                  child: const Text('Verify'),
                ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _resend,
                  child: const Text("Didn't receive a code? Resend",
                    style: TextStyle(color: AppColors.primary)),
                ),
              ),

              // Dev hint
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'DEV MODE: use code 123456',
                      style: TextStyle(fontSize: 13, color: Colors.amber),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
