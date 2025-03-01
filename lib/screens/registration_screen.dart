import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  UserType _selectedUserType = UserType.consumer;
} 