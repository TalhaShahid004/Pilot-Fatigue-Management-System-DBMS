import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/fatigue_calculator.dart';
import 'package:intl/intl.dart';

class ModerateRiskFlightsScreen extends StatelessWidget {
  const ModerateRiskFlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Moderate Risk Flights',
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
                'Moderate Risk Flights',
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
                      .collection('moderateFlights')
                      .orderBy('startTime', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
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
                          'No moderate flights found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: flights.length,
                      itemBuilder: (context, index) {
                        final flightData = flights[index].data() as Map<String, dynamic>;
                        final startTime = (flightData['startTime'] as Timestamp).toDate();
                        final pilots = List<Map<String, dynamic>>.from(flightData['pilots'] ?? []);
                        
                     return FutureBuilder<List<double>>(
                          future: Future.wait(pilots.map((pilot) =>
                              _getPilotFatigueScore(
                                  pilot['pilotId'], flights[index].id))),
                          builder: (context, scoreSnapshot) {
                            double avgFatigueScore = 0;
                            if (scoreSnapshot.hasData) {
                              final scores = scoreSnapshot.data!;
                              if (scores.isNotEmpty) {
                                avgFatigueScore =
                                    scores.reduce((a, b) => a + b) /
                                        scores.length;
                              }
                            }

                        return Column(
                          children: [
                            _buildFlightCard(
                              flightNumber: flightData['flightNumber'] ?? 'N/A',
                              route: flightData['route'] ?? 'N/A',
                              startTime: startTime,
                              flightRisk: avgFatigueScore / 10,
                              status: flightData['status'] ?? 'N/A',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/flight_details_operations',
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
      
Future<double> _getPilotFatigueScore(String pilotId, String flightId) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    print('Calculating fatigue score for pilot: $pilotId, flight: $flightId');
    
    // Get pilot metrics
    final metricsDoc = await firestore
        .collection('pilotMetrics')
        .doc(pilotId)
        .get();
    
    if (!metricsDoc.exists) {
      print('No metrics found for pilot: $pilotId');
      return 0.0;
    }
    
    final metrics = metricsDoc.data();
    print('Retrieved metrics: $metrics');
    
    // Get fatigue assessment
    final assessmentQuery = await firestore
        .collection('fatigueAssessments')
        .where('pilotId', isEqualTo: pilotId)
        .where('flightId', isEqualTo: flightId)
        .limit(1)
        .get();
        
    final assessment = assessmentQuery.docs.isNotEmpty ? 
        assessmentQuery.docs.first.data() : null;

    if (metrics != null) {
      final flightHoursRaw = FatigueCalculator.normalizeFlightHoursWeek(
        metrics['totalFlightHoursLast7Days'] ?? 0);
      final flightHoursWeighted = flightHoursRaw * 0.30;

      final timeZoneRaw = FatigueCalculator.normalizeTimeZones(
        metrics['timeZonesCrossedLast24Hours'] ?? 0);
      final timeZoneWeighted = timeZoneRaw * 0.25;

      final restPeriodRaw = FatigueCalculator.calculateRestPeriodScore(
        metrics['lastRestPeriodEnd'],
        assessment?['questions']?['hoursSleptLast24'] ?? 8);
      final restPeriodWeighted = restPeriodRaw * 0.20;

      final flightDurationRaw = FatigueCalculator.normalizeFlightDuration(
        metrics['currentDutyPeriodDuration'] ?? 0);
      final flightDurationWeighted = flightDurationRaw * 0.15;

      final selfAssessmentRaw = assessment != null ? 
        FatigueCalculator.normalizeSelfAssessment(assessment['questions']) : 0.5;
      final selfAssessmentWeighted = selfAssessmentRaw * 0.10;

      return flightHoursWeighted +
          timeZoneWeighted +
          restPeriodWeighted +
          flightDurationWeighted +
          selfAssessmentWeighted;
    }
    
    return 0.0;
  } catch (e) {
    print('Error calculating pilot fatigue score: $e');
    return 0.0;
  }
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
          color: const Color(0xFF242200), // Moderate risk background color
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBF6A02), // Moderate risk text color
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
                color: const Color(0xFF342F00), // Darker shade for status background
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