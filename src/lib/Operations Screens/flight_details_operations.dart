import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Operations%20Screens/fatigue_details.dart';
import 'package:flutter_application_1/Operations%20Screens/manage_flight.dart';
import 'package:flutter_application_1/utils/fatigue_calculator.dart';
import 'package:intl/intl.dart';

class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String flightId =
        ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Flight Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('criticalFlights')
            .doc(flightId)
            .snapshots(),
        builder: (context, criticalSnapshot) {
          if (criticalSnapshot.hasError) {
            return const Center(
              child: Text('Something went wrong',
                  style: TextStyle(color: Colors.white)),
            );
          }

          if (criticalSnapshot.hasData && criticalSnapshot.data!.exists) {
            return _buildFlightDetails(
                context, criticalSnapshot.data!, flightId, 'Critical');
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('moderateFlights')
                .doc(flightId)
                .snapshots(),
            builder: (context, moderateSnapshot) {
              if (moderateSnapshot.hasData && moderateSnapshot.data!.exists) {
                return _buildFlightDetails(
                    context, moderateSnapshot.data!, flightId, 'Moderate');
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('healthyFlights')
                    .doc(flightId)
                    .snapshots(),
                builder: (context, healthySnapshot) {
                  if (healthySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!healthySnapshot.hasData ||
                      !healthySnapshot.data!.exists) {
                    return const Center(
                      child: Text('Flight not found',
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  return _buildFlightDetails(
                      context, healthySnapshot.data!, flightId, 'Healthy');
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFlightDetails(
    BuildContext context,
    DocumentSnapshot flightDoc,
    String flightId,
    String riskCategory,
  ) {
    final flightData = flightDoc.data() as Map<String, dynamic>;
    final startTime = flightData['startTime'] as Timestamp;
    final endTime = flightData['endTime'] as Timestamp;
    final pilots = List<Map<String, dynamic>>.from(flightData['pilots'] ?? [])
        .map((pilot) => {
              ...pilot,
              'name': pilot['name'] ?? 'Unknown',
              'role': pilot['role'] ?? 'Unknown',
              'pilotId': pilot['pilotId'] ?? '',
              'fatigueScore': pilot['fatigueScore'] ?? 0.0,
            })
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flight Status Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        flightData['flightNumber'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(flightData['status']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          flightData['status'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flightData['route'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Time and Duration Card
            _buildCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconLabel(
                          Icons.calendar_today,
                          'Date & Time',
                          _formatDateTime(startTime, endTime),
                        ),
                        const SizedBox(height: 16),
                        _buildIconLabel(
                          Icons.timer,
                          'Duration',
                          '${flightData['duration']} minutes',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Flight Crew Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people, color: Colors.white70, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Flight Crew',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...pilots
                      .map((pilot) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E4B61),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      pilot['name'][0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pilot['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      pilot['role'],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Risk Assessment Card
            _buildCard(
              child: _buildEnhancedRiskSection(pilots, riskCategory, flightId),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.analytics,
                    label: 'Fatigue Details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FatigueDetailsScreen(
                            flightId: flightId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.settings,
                    label: 'Manage Flight',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageFlightScreen(
                            flightId: flightId,
                            flightData: flightData,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21384A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIconLabel(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedRiskSection(
      List<Map<String, dynamic>> pilots, String riskCategory, String flightId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning, color: Colors.white70, size: 24),
            SizedBox(width: 8),
            Text(
              'Risk Assessment',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getRiskColor(riskCategory),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            riskCategory,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...pilots
            .map((pilot) => FutureBuilder<Map<String, dynamic>>(
                  future: _getPilotFatigueDetails(pilot['pilotId'], flightId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final fatigueDetails = snapshot.data ?? {};

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E4B61),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C2E3D),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    pilot['name'][0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pilot['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    pilot['role'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2E3D),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.speed,
                                    color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'FI: ${fatigueDetails['finalScore']?.toStringAsFixed(2) ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ))
            .toList(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E4B61),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(Timestamp start, Timestamp end) {
    final startTime = start.toDate();
    final endTime = end.toDate();
    final dateFormat = DateFormat('d MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(startTime)}\n${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskColor(String category) {
    switch (category.toLowerCase()) {
      case 'critical':
        return const Color(0xFFD32F2F);
      case 'moderate':
        return const Color(0xFFF57C00);
      case 'healthy':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  Future<Map<String, dynamic>> _getPilotFatigueDetails(
      String pilotId, String flightId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Get pilot metrics
      final metricsDoc =
          await firestore.collection('pilotMetrics').doc(pilotId).get();

      final metrics = metricsDoc.exists ? metricsDoc.data() : null;

      // Get fatigue assessment
      final assessmentQuery = await firestore
          .collection('fatigueAssessments')
          .where('pilotId', isEqualTo: pilotId)
          .where('flightId', isEqualTo: flightId)
          .limit(1)
          .get();

      final assessment = assessmentQuery.docs.isNotEmpty
          ? assessmentQuery.docs.first.data()
          : null;

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

        final selfAssessmentRaw = assessment != null
            ? FatigueCalculator.normalizeSelfAssessment(assessment['questions'])
            : 0.5;
        final selfAssessmentWeighted = selfAssessmentRaw * 0.10;

        final finalScore = flightHoursWeighted +
            timeZoneWeighted +
            restPeriodWeighted +
            flightDurationWeighted +
            selfAssessmentWeighted;

        return {
          'finalScore': finalScore,
        };
      }

      return {};
    } catch (e) {
      print('Error fetching pilot fatigue details: $e');
      return {};
    }
  }
}
