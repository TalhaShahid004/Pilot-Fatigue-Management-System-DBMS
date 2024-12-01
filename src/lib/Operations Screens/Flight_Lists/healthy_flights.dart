import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthyRiskFlightsScreen extends StatelessWidget {
  const HealthyRiskFlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Healthy Risk Flights',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/flight_risk'));
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Healthy Risk Flights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('healthyFlights')
                      .orderBy('startTime', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Something went wrong',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final flights = snapshot.data!.docs;

                    if (flights.isEmpty) {
                      return const Center(
                        child: Text(
                          'No healthy flights found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: flights.length,
                      itemBuilder: (context, index) {
                        final flightData =
                            flights[index].data() as Map<String, dynamic>;
                        final startTime =
                            (flightData['startTime'] as Timestamp).toDate();
                        final pilots = List<Map<String, dynamic>>.from(
                            flightData['pilots'] ?? []);

                        // Calculate average fatigue score
                        double avgFatigueScore = 0;
                        if (pilots.isNotEmpty) {
                          final totalFatigue = pilots.fold(
                              0.0,
                              (sum, pilot) =>
                                  sum + (pilot['fatigueScore'] ?? 0));
                          avgFatigueScore = totalFatigue / pilots.length;
                        }

                        return Column(
                          children: [
                            _buildFlightCard(
                              flightNumber: flightData['flightNumber'] ?? 'N/A',
                              route: flightData['route'] ?? 'N/A',
                              startTime: startTime,
                              flightRisk:
                                  avgFatigueScore / 10, // Convert to 1-10 scale
                              status: flightData['status'] ?? 'N/A',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/flight_details_operations', // This matches your route definition
                                  arguments: flights[index].id,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightCard({
    required String flightNumber,
    required String route,
    required DateTime startTime,
    required double flightRisk,
    required String status,
    required VoidCallback onTap,
  }) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF21384A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flightNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'FI: ${flightRisk.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(startTime)} ${timeFormat.format(startTime)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E4B61),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
