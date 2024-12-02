import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/fatigue_calculator.dart';
import 'package:intl/intl.dart';

class FatigueDetailsScreen extends StatelessWidget {
  final String flightId;

  const FatigueDetailsScreen({
    super.key,
    required this.flightId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Fatigue Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('flights')
            .doc(flightId)
            .snapshots(),
        builder: (context, flightSnapshot) {
          if (!flightSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final flightData =
              flightSnapshot.data!.data() as Map<String, dynamic>;
          final pilots = List<Map<String, dynamic>>.from(flightData['pilots']);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pilots.length,
            itemBuilder: (context, index) {
              final pilot = pilots[index];
              return _buildPilotFatigueCard(pilot);
            },
          );
        },
      ),
    );
  }

  Widget _buildPilotFatigueCard(Map<String, dynamic> pilot) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pilotMetrics')
          .doc(pilot['pilotId'])
          .snapshots(),
      builder: (context, metricsSnapshot) {
return FutureBuilder<QuerySnapshot>(
  future: FirebaseFirestore.instance
      .collection('fatigueAssessments')
      .where('pilotId', isEqualTo: pilot['pilotId'])
      .where('flightId', isEqualTo: flightId)
      .limit(1)
      .get(),
  builder: (context, assessmentSnapshot) {
    final metrics = metricsSnapshot.hasData
        ? metricsSnapshot.data!.data() as Map<String, dynamic>?
        : null;
    final assessment = assessmentSnapshot.hasData && assessmentSnapshot.data!.docs.isNotEmpty
        ? assessmentSnapshot.data!.docs.first.data() as Map<String, dynamic>?
        : null;
            return Card(
              color: const Color(0xFF21384A),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPilotHeader(pilot),
                    const Divider(color: Colors.white24, height: 32),
                    if (metrics != null) ...[
                      _buildMetricSection('Flight Hours (7 Days)',
                          '${metrics['totalFlightHoursLast7Days']?.toString() ?? 'N/A'} hrs'),
                      _buildMetricSection(
                          'Time Zones Crossed',
                          metrics['timeZonesCrossedLast24Hours']?.toString() ??
                              'N/A'),
                      _buildMetricSection('Hours Since Last Rest',
                          _formatRestPeriod(metrics['lastRestPeriodEnd'])),
                    ],
                    if (assessment != null &&
                        assessment['questions'] != null) ...[
                      const Divider(color: Colors.white24, height: 32),
                      const Text(
                        'Self Assessment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricSection('Sleep Quality',
                          '${assessment['questions']['sleepQuality']}/10'),
                      _buildMetricSection('Alertness Level',
                          '${assessment['questions']['alertnessLevel']}/7'),
                      _buildMetricSection('Stress Level',
                          '${assessment['questions']['stressLevel']}/10'),
                      _buildMetricSection('Hours Slept (24h)',
                          '${assessment['questions']['hoursSleptLast24']} hrs'),
                    ],
                    const Divider(color: Colors.white24, height: 32),
                    _buildFatigueScore(metrics, assessment),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPilotHeader(Map<String, dynamic> pilot) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2E4B61),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              pilot['name'][0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pilot['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
        ),
      ],
    );
  }

  Widget _buildMetricSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// Replace all existing weight calculation methods with:
  double _normalizeFlightHoursWeek(num hours) {
    // Normalize 0-100 hours to 0-1
    final normalized = hours / 100;
    return normalized.clamp(0.0, 1.0);
  }

  double _normalizeTimeZones(num zones) {
    // Normalize 0-8 timezone crosses to 0-1
    final normalized = zones / 8;
    return normalized.clamp(0.0, 1.0);
  }

  double _calculateRestPeriodScore(Timestamp? lastRest, double hoursSlept) {
    if (lastRest == null) return 1.0; // Worst case

    final hoursSinceRest = DateTime.now().difference(lastRest.toDate()).inHours;

    // Normalize components
    final restTimingScore =
        (24 - hoursSinceRest.clamp(0, 24)) / 24; // Higher is better
    final sleepScore = hoursSlept / 12; // Normalize against ideal 12 hours

    // Combined rest period score (0-1, where 1 is most fatigued)
    return 1 - ((restTimingScore * 0.6 + sleepScore * 0.4).clamp(0.0, 1.0));
  }

  double _normalizeFlightDuration(num duration) {
    // Normalize 0-16 hours to 0-1
    final normalized = duration / 16;
    return normalized.clamp(0.0, 1.0);
  }

double _normalizeSelfAssessment(Map<String, dynamic> assessment) {
  // Convert sleep quality string back to number
  final sleepQualityMap = {
    'Excellent': 9.0,
    'Good': 7.0,
    'Fair': 5.0,
    'Poor': 3.0,
    'Very Poor': 1.0
  };
  
  final alertness = (assessment['questions']['alertnessLevel'] as num) / 7;
  final stress = (assessment['questions']['stressLevel'] as num) / 10;
  final sleepQuality = sleepQualityMap[assessment['questions']['sleepQuality']] ?? 5.0;
  final normalizedSleepQuality = sleepQuality / 10;

  // Combine factors (1 is most fatigued)
  return 1 -
      ((alertness * 0.4 + (1 - stress) * 0.3 + normalizedSleepQuality * 0.3)
          .clamp(0.0, 1.0));
}

Widget _buildFatigueScore(
  Map<String, dynamic>? metrics,
  Map<String, dynamic>? assessment,
) {
  return FutureBuilder<Map<String, double>>(
    future: _calculateFatigueBreakdown(metrics, assessment),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final breakdown = snapshot.data ?? {};
      final double fatigueIndex = breakdown['finalScore'] ?? 0.0;

      return Column(
        children: [
          // Score Breakdown Section
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E4B61),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Score Breakdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildScoreRow('Flight Hours (30%)', 
                  breakdown['flightHoursRaw'] ?? 0, 
                  breakdown['flightHoursWeighted'] ?? 0),
                _buildScoreRow('Time Zones (25%)', 
                  breakdown['timeZoneRaw'] ?? 0, 
                  breakdown['timeZoneWeighted'] ?? 0),
                _buildScoreRow('Rest Period (20%)', 
                  breakdown['restPeriodRaw'] ?? 0, 
                  breakdown['restPeriodWeighted'] ?? 0),
                _buildScoreRow('Flight Duration (15%)', 
                  breakdown['flightDurationRaw'] ?? 0, 
                  breakdown['flightDurationWeighted'] ?? 0),
                _buildScoreRow('Self Assessment (10%)', 
                  breakdown['selfAssessmentRaw'] ?? 0, 
                  breakdown['selfAssessmentWeighted'] ?? 0),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Final Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fatigueIndex.toStringAsFixed(2),
                      style: TextStyle(
                        color: _getFatigueColor(fatigueIndex),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Final Score Display
          const Text(
            'Fatigue Index',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _getFatigueColor(fatigueIndex),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fatigueIndex.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildScoreRow(String label, double rawScore, double weightedScore) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
          '${rawScore.toStringAsFixed(2)} → ${weightedScore.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

Future<Map<String, double>> _calculateFatigueBreakdown(
  Map<String, dynamic>? metrics,
  Map<String, dynamic>? assessment,
) async {
  if (metrics == null) return {};

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

  final finalScore = flightHoursWeighted +
      timeZoneWeighted +
      restPeriodWeighted +
      flightDurationWeighted +
      selfAssessmentWeighted;

  return {
    'flightHoursRaw': flightHoursRaw,
    'flightHoursWeighted': flightHoursWeighted,
    'timeZoneRaw': timeZoneRaw,
    'timeZoneWeighted': timeZoneWeighted,
    'restPeriodRaw': restPeriodRaw,
    'restPeriodWeighted': restPeriodWeighted,
    'flightDurationRaw': flightDurationRaw,
    'flightDurationWeighted': flightDurationWeighted,
    'selfAssessmentRaw': selfAssessmentRaw,
    'selfAssessmentWeighted': selfAssessmentWeighted,
    'finalScore': finalScore,
  };
}

Future<void> _updateFlightRiskCategory(
  String flightId, 
  String newCategory, 
  Map<String, dynamic> flightData
) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Remove from old collection
  if (flightData['riskCategory'] != null) {
    final oldCollectionRef = firestore.collection('${flightData['riskCategory'].toLowerCase()}Flights');
    batch.delete(oldCollectionRef.doc(flightId));
  }

  // Add to new collection
  final newCollectionRef = firestore.collection('${newCategory.toLowerCase()}Flights');
  batch.set(newCollectionRef.doc(flightId), {
    ...flightData,
    'riskCategory': newCategory,
  });

  // Update main flight document
  final flightRef = firestore.collection('flights').doc(flightId);
  batch.update(flightRef, {'riskCategory': newCategory});

  await batch.commit();
}
  // Helper methods
  String _formatRestPeriod(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final hours = DateTime.now().difference(timestamp.toDate()).inHours;
    return '$hours hours ago';
  }

  Color _getWeightColor(double weight) {
    if (weight >= 0.8) return Colors.red;
    if (weight >= 0.6) return Colors.orange;
    if (weight >= 0.4) return Colors.amber;
    return Colors.green;
  }

  Color _getFatigueColor(double index) {
    if (index >= 0.8) return Colors.red;
    if (index >= 0.6) return Colors.orange;
    if (index >= 0.4) return Colors.amber;
    return Colors.green;
  }
}
