// Bismillah - Started Project 15-05-1446/18-11-2024

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Authentication Screens/login.dart';
import 'Authentication Screens/signup.dart';
import 'Pilot Screens/dashboard.dart';
import 'Pilot Screens/flight_assessment.dart';

import 'Operations Screens/dashboard.dart';
import 'Operations Screens/Flight_Lists/critical_flights.dart';
import 'Operations Screens/Flight_Lists/moderate_flights.dart';
import 'Operations Screens/Flight_Lists/healthy_flights.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PFMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414),
        primaryColor: const Color(0xFF2194F2),
        inputDecorationTheme: InputDecorationTheme(
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
      // Define the initial route
      initialRoute: '/login',

      // Define all routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/flight_assessment': (context) => const FlightAssessmentScreen(),
        '/flight_risk': (context) => const OperationsDashboardScreen(),
        '/critical_risk_flights': (context) =>
            const CriticalRiskFlightsScreen(),
        '/moderate_risk_flights': (context) =>
            const ModerateRiskFlightsScreen(),
        '/healthy_risk_flights': (context) => const HealthyRiskFlightsScreen(),
      },
    );
  }
}
