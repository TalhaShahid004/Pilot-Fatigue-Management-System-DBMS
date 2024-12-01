// lib/screens/operations/profile_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class OperationsProfileScreen extends StatefulWidget {
  const OperationsProfileScreen({super.key});

  @override
  State<OperationsProfileScreen> createState() => _OperationsProfileScreenState();
}

class _OperationsProfileScreenState extends State<OperationsProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers for form fields
  String? _email;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // In _OperationsProfileScreenState class
// In OperationsProfileScreen
Future<void> _loadUserData() async {
  try {
    final userData = await _authService.getCurrentUserData();
    setState(() {
      _email = userData['email'];  // This will now be the document ID
      _firstNameController.text = userData['firstName'] ?? '';
      _lastNameController.text = userData['lastName'] ?? '';
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Error loading profile data: ${e.toString()}';
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
      await _authService.updateOperationsProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}