// Bismillah - Started Project 15-05-1446/18-11-2024

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Pilot%20Screens/profile.dart';
import 'Authentication Screens/login.dart';
import 'Authentication Screens/signup.dart';
import 'Pilot Screens/dashboard.dart';
import 'Pilot Screens/fatigue_assessment.dart';
import 'Pilot Screens/flight_details_pilot.dart';

import 'Operations Screens/operationDashboard.dart';

import 'Operations Screens/operationProfile.dart';
import 'Operations Screens/flight_details_operations.dart';
import 'Operations Screens/fatigue_details.dart';
import 'Operations Screens/manage_flight.dart';
import 'Operations Screens/Flight_Lists/critical_flights.dart';
import 'Operations Screens/Flight_Lists/moderate_flights.dart';
import 'Operations Screens/Flight_Lists/healthy_flights.dart';

import 'Admin Screens/admin_dashboard.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('before firebase initialization');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  print('firebase initialized');
  runApp(const MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   print('before firebase initialization');

//   try {
//     await Firebase.initializeApp();
//     print('firebase initialized');
//   } catch (e) {
//     print('Firebase initialization error: $e');
//   }
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//   runApp(const MyApp());
// }

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
        '/flight_details_operations': (context) => const FlightDetailsScreen(),
        'fatigue_details': (context) => const FatigueDetailsScreen(flightId: 'PK301'),
        '/profile': (context) => const ProfileScreen(),
        '/operation_profile': (context) => const OperationsProfileScreen(),
        '/operation_dashboard': (context) => const OperationsDashboardScreen(),
        '/flight_details_pilot': (context) => const PilotFlightDetailsScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
