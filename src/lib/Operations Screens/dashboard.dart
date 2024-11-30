import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/populate_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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