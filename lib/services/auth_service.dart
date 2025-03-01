import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebase.PhoneAuthCredential credential) async {
        // Auto-verification handled here (Android only)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (firebase.FirebaseAuthException e) {
        throw Exception('Verification Failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Store verificationId for later use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('verificationId', verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verificationId = prefs.getString('verificationId');
      
      if (verificationId == null) return false;

      final credential = firebase.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      return false;
    }
  }

  // Register user after phone verification
  Future<User?> registerUser({
    required String name,
    required String phone,
    required UserType userType,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final user = User(
        id: firebaseUser.uid,
        name: name,
        email: '', // Optional in this case
        userType: userType,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      // Save user to PostgreSQL
      await DatabaseService().saveUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      return await DatabaseService().getUserById(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 