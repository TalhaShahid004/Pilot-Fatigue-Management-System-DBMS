// lib/screens/pilot/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers for form fields
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _email;
  final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      setState(() {
        _email = userData['email'];
        _licenseController.text = userData['licenseNumber'] ?? '';
        _experienceController.text = userData['experience']?.toString() ?? '';
        _phoneController.text = userData['phoneNumber'] ?? '';
        _isLoading = false;
        _firstNameController.text = userData['firstName'] ?? '';
_lastNameController.text = userData['lastName'] ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile data';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
     await _authService.updatePilotProfile(
  licenseNumber: _licenseController.text,
  experience: _experienceController.text,
  phoneNumber: _phoneController.text,
  firstName: _firstNameController.text,  // Add this
  lastName: _lastNameController.text,    // Add this
);

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    _buildField(
                      label: 'Email',
                      controller: TextEditingController(text: _email),
                      enabled: false,
                    ),
                    _buildField(
                      label: 'License Number',
                      controller: _licenseController,
                      enabled: _isEditing,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'License number is required' : null,
                    ),
                    _buildField(
                      label: 'Years of Experience',
                      controller: _experienceController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Experience is required';
                        final years = int.tryParse(value!);
                        if (years == null || years < 0 || years > 50) {
                          return 'Enter valid years (0-50)';
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
  label: 'First Name',
  controller: _firstNameController,
  enabled: _isEditing,
  validator: (value) =>
      value?.isEmpty ?? true ? 'First name is required' : null,
),
_buildField(
  label: 'Last Name',
  controller: _lastNameController,
  enabled: _isEditing,
  validator: (value) =>
      value?.isEmpty ?? true ? 'Last name is required' : null,
),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white60,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF21384A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
_lastNameController.dispose();
    super.dispose();
  }
}