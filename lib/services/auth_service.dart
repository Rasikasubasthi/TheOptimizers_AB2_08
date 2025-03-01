import 'package:crypto/crypto.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  late TwilioFlutter _twilioFlutter;
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _twilioFlutter = TwilioFlutter(
      accountSid: dotenv.env['TWILIO_ACCOUNT_SID'] ?? '',
      authToken: dotenv.env['TWILIO_AUTH_TOKEN'] ?? '',
      twilioNumber: dotenv.env['TWILIO_PHONE_NUMBER'] ?? '',
    );
  }

  String _generateOTP() {
    return Random().nextInt(900000 + 100000).toString();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> sendOTP(String phoneNumber) async {
    final otp = _generateOTP();
    
    // Save OTP to database with expiration
    await DatabaseService()._connection.execute('''
      INSERT INTO otp_verifications (id, phone, otp, expires_at)
      VALUES (uuid_generate_v4(), @phone, @otp, NOW() + INTERVAL '5 minutes')
    ''', substitutionValues: {
      'phone': phoneNumber,
      'otp': otp,
    });

    // Send OTP via Twilio
    await _twilioFlutter.sendSMS(
      toNumber: phoneNumber,
      messageBody: 'Your OTP for Farmer Marketplace is: $otp',
    );
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    final results = await DatabaseService()._connection.query('''
      UPDATE otp_verifications
      SET verified = TRUE
      WHERE phone = @phone 
        AND otp = @otp 
        AND expires_at > NOW()
        AND verified = FALSE
      RETURNING id
    ''', substitutionValues: {
      'phone': phoneNumber,
      'otp': otp,
    });

    return results.isNotEmpty;
  }

  Future<User?> login(String phoneNumber, String password) async {
    final results = await DatabaseService()._connection.query('''
      SELECT * FROM users WHERE phone = @phone AND password_hash = @hash
    ''', substitutionValues: {
      'phone': phoneNumber,
      'hash': _hashPassword(password),
    });

    if (results.isEmpty) return null;

    final userData = results.first;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userData[0]);
    
    return User.fromMap(Map<String, dynamic>.from(userData));
  }
} 