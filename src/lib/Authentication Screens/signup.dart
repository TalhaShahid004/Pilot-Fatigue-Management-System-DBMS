import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2194F2),
              surface: Color(0xFF21384A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  _buildFormField(
                    label: 'Username/Email',
                    hintText: 'Your username or email',
                  ),
                  
                  _buildFormField(
                    label: 'Password',
                    hintText: 'Your password',
                    isPassword: true,
                  ),
                  
                  _buildFormField(
                    label: 'Professional License Number',
                    hintText: 'Your professional license number',
                  ),
                  
                  _buildFormField(
                    label: 'Years of Experience',
                    hintText: 'How many years have you been working?',
                    isNumeric: true,
                  ),
                  
                  _buildFormField(
                    label: 'Date of Birth',
                    hintText: 'MM/DD/YYYY',
                    controller: _dateController,
                    onTap: () => _selectDate(context),
                    readOnly: true,
                  ),
                  
                  _buildFormField(
                    label: 'Phone Number (optional)',
                    hintText: 'Your phone number',
                    isRequired: false,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2194F2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to dashboard regardless of validation
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    bool isPassword = false,
    bool isNumeric = false,
    bool isRequired = true,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          readOnly: readOnly,
          keyboardType: keyboardType ?? (isNumeric ? TextInputType.number : TextInputType.text),
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF8FB0CC)),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF8FB0CC),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}