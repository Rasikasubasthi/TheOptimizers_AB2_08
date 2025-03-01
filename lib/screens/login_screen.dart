import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _otpSent = false;
  bool _otpVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
              ),
              keyboardType: TextInputType.phone,
              enabled: !_otpVerified,
            ),
            const SizedBox(height: 16),
            if (!_otpSent)
              ElevatedButton(
                onPressed: () async {
                  await AuthService().sendOTP(_phoneController.text);
                  setState(() => _otpSent = true);
                },
                child: const Text('Send OTP'),
              ),
            if (_otpSent && !_otpVerified) ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final verified = await AuthService()
                      .verifyOTP(_phoneController.text, _otpController.text);
                  setState(() => _otpVerified = verified);
                },
                child: const Text('Verify OTP'),
              ),
            ],
            if (_otpVerified) ...[
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final user = await AuthService().login(
                    _phoneController.text,
                    _passwordController.text,
                  );
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => user.userType == UserType.farmer
                            ? const FarmerDashboard()
                            : const ConsumerDashboard(),
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 