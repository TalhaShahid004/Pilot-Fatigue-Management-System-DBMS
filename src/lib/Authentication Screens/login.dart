import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Future<void> fetchData() async {
//   final response = await http.get(Uri.parse('http://localhost:3000/data'));
//   if (response.statusCode == 200) {
//     print(jsonDecode(response.body));
//     print('Working!');
//   } else {
//     print('Failed to fetch data');
//   }
// }

Future<bool> login(String username, String password) async {
  Map data = {'username': username, 'password': password};
  //encode Map to JSON
  var body = json.encode(data);
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/login_verification'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      print('Server returned error: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Login API call failed: $e');
    return false;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(BuildContext context) async {
    String username = _emailController.text;
    String password = _passwordController.text;

    print('Attempting login with username: $username and password: $password');

    // Call the login API
    bool isLoginSuccessful = await login(username, password);

    print('Login result: $isLoginSuccessful');

    if (mounted) {
      // Check if the widget is still in the tree
      if (isLoginSuccessful) {
        print('Login successful, navigating to dashboard...');
        // Navigator.pushNamed(context, '/dashboard');
        Navigator.pushNamed(
          context,
          '/dashboard',
          arguments: {
            'username': username,
            'password': password,
          },
        );
      } else {
        print('Login failed, staying on login screen.');
        // Optionally, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21384A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Username or Email',
                      hintStyle: TextStyle(
                        color: Color(0xFF8FB0CC),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21384A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8FB0CC),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF8FB0CC),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFF8FB0CC),
                      fontSize: 14,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    // // TODO: ADD FUNCTIONALITY HERE
                    // // Extract the text from the controllers
                    // String username = _emailController.text;
                    // String password = _passwordController.text;

                    // // Now you can use the extracted username and password, for example, call your login API:
                    // bool isLoginSuccessful = await login(username, password);

                    // // For now, just navigate to pilot dashboard
                    // Navigator.pushNamed(context, '/dashboard');

                    // Call the async login handler function
                    print("handling login");
                    _handleLogin(context);
                    print("handled login");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2194F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    'New user? Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
