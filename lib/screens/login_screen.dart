import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../lib/screens/registration_screen.dart'; // Add this import
import 'farmer_dashboard.dart'; // Add this import
import 'consumer_dashboard.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

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
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              enabled: !_otpSent,
            ),
            const SizedBox(height: 16),
            if (!_otpSent)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await AuthService().sendOTP(_phoneController.text);
                    setState(() => _otpSent = true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Send OTP'),
              ),
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final verified = await AuthService().verifyOTP(_otpController.text);
                  if (verified) {
                    final user = await AuthService().getCurrentUser();
                    if (user != null) {
                      // User exists, navigate to dashboard
                      _navigateToDashboard(context, user);
                    } else {
                      // New user, navigate to registration
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid OTP')),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Verify & Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user.userType == UserType.farmer
            ? const FarmerDashboard()
            : const ConsumerDashboard(),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
} 