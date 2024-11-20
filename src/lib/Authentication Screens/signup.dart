import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final TextEditingController _dateController = TextEditingController();

  // Controllers for each field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _airlineCodeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _licenseNumberController =
  //     TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  // final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    void _onSubmit() async {
      // Collect data from controllers
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();
      // final String licenseNumber = _licenseNumberController.text.trim();
      final String experience = _experienceController.text.trim();
      final String dateOfBirth = _dateController.text.trim();
      final String phone = _phoneController.text.trim();
      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();
      final String airlineCode = _airlineCodeController.text.trim();
      final String email = _emailController.text.trim();

      // Print or save data
      print('Username: $username');
      print('Password: $password');
      // print('License Number: $licenseNumber');
      print('Experience: $experience');
      print('Date of Birth: $dateOfBirth');
      print('First Name: $firstName');
      print('Last Name: $lastName');
      print('Airline Code: $airlineCode');
      print('Email: $email');
      print('Phone number: $phone');

      // Create a map of the data to send to the server
      final Map<String, dynamic> pilotData = {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'password': password,
        'airline_code': airlineCode,
        'experience': experience,
        'date_of_birth': dateOfBirth,
        'email': email,
        'contact_number': phone,
      };

      // Validate form
      if (!_formKey.currentState!.validate()) {
        print("Form not validated, exiting!");
        return; // If validation fails, return early
      }

      // Send POST request to the Node.js backend
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/registerPilot'), // Change this to your backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pilotData),
      );

      // Handle the server response
      if (response.statusCode == 200) {
        // If the pilot is successfully registered
        final responseBody = json.decode(response.body);
        print(
            'Pilot registered successfully. Pilot ID: ${responseBody['pilot_id']}');
        Navigator.pushNamed(context, '/login'); // Redirect to login
      } else {
        // If an error occurred
        print('Failed to register pilot: ${response.body}');
      }

      // Add validation or processing logic here
      Navigator.pushNamed(context, '/login');
    }

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
                      label: 'First Name',
                      hintText: 'Your first name',
                      controller: _firstNameController),
                  _buildFormField(
                      label: 'Last Name',
                      hintText: 'Your last name',
                      controller: _lastNameController),
                  _buildFormField(
                      label: 'Username',
                      hintText: 'Your username',
                      controller: _usernameController),
                  _buildFormField(
                      label: 'Password',
                      hintText: 'Your password',
                      isPassword: true,
                      controller: _passwordController),
                  _buildFormField(
                      label: 'Airline Code',
                      hintText: 'Your airline code',
                      controller: _airlineCodeController),
                  _buildFormField(
                      label: 'Years of Experience',
                      hintText: 'How many years have you been working?',
                      isNumeric: true,
                      controller: _experienceController),
                  _buildFormField(
                    label: 'Date of Birth',
                    hintText: 'MM/DD/YYYY',
                    controller: _dateController,
                    onTap: () => _selectDate(context),
                    readOnly: true,
                  ),
                  _buildFormField(
                      label: 'Email',
                      hintText: 'Your email',
                      controller: _emailController),
                  _buildFormField(
                      label: 'Phone Number (optional)',
                      hintText: 'Your phone number',
                      isRequired: false,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2194F2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _onSubmit, // () {
                    //   // Navigate to dashboard regardless of validation
                    //   Navigator.pushNamed(context, '/dashboard');
                    // },
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
          keyboardType: keyboardType ??
              (isNumeric ? TextInputType.number : TextInputType.text),
          inputFormatters:
              isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF8FB0CC)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF8FB0CC),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
