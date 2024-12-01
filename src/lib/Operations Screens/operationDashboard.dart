import 'package:flutter/material.dart';
import 'package:flutter_application_1/Operations%20Screens/operationProfile.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/populate_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Operations Screens/operationProfile.dart';


class OperationsDashboardScreen extends StatelessWidget {
  const OperationsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Flight Risk Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final populator = DataPopulationUtil();
              await populator.populateAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data populated successfully')),
                );
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('operationalMetrics')
              .doc('PIA')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong', 
                  style: TextStyle(color: Colors.white)
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {
              'criticalFlightsCount': 0,
              'moderateFlightsCount': 0,
              'healthyFlightsCount': 0,
            };

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRiskButton(
                      label: 'Critical',
                      flightCount: data['criticalFlightsCount'] ?? 0,
                      onPressed: () {
                        Navigator.pushNamed(context, '/critical_risk_flights');
                      },
                      icon: Icons.warning_amber_rounded,
                      backgroundColor: const Color(0xFF3A2627),
                      textColor: const Color(0xFFF3745C),
                    ),
                    const SizedBox(height: 16),
                    _buildRiskButton(
                      label: 'Moderate',
                      flightCount: data['moderateFlightsCount'] ?? 0,
                      onPressed: () {
                        Navigator.pushNamed(context, '/moderate_risk_flights');
                      },
                      icon: Icons.info_outline,
                      backgroundColor: const Color(0xFF242200),
                      textColor: const Color(0xFFBF6A02),
                    ),
                    const SizedBox(height: 16),
                    _buildRiskButton(
                      label: 'Healthy',
                      flightCount: data['healthyFlightsCount'] ?? 0,
                      onPressed: () {
                        Navigator.pushNamed(context, '/healthy_risk_flights');
                      },
                      icon: Icons.check_circle_outline,
                      backgroundColor: const Color(0xFF0E281A),
                      textColor: const Color(0xFF4BA03E),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
  final AuthService _authService = AuthService();

  return Drawer(
    child: Container(
      color: const Color(0xFF21384A),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF2194F2),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                  future: _authService.getCurrentUserEmail(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Operations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OperationsProfileScreen(),
                ),
              );
            },
          ),
          const Spacer(), // Pushes the logout button to the bottom
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white24),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildRiskButton({
    required String label,
    required int flightCount,
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side content
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      icon,
                      color: textColor,
                      size: 34,
                    ),
                  ],
                ),
                // Right side content
                Text(
                  '$flightCount flights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: textColor,
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

// Function to initialize operational metrics
Future<void> _initializeOperationalMetrics() async {
  final firestore = FirebaseFirestore.instance;
  
  await firestore.collection('operationalMetrics').doc('PIA').set({
    'criticalFlightsCount': 0,
    'moderateFlightsCount': 0,
    'healthyFlightsCount': 0,
    'lastUpdated': FieldValue.serverTimestamp(),
  });
}