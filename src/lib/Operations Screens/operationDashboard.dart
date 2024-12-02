import 'package:flutter/material.dart';
import 'package:flutter_application_1/Operations%20Screens/operationProfile.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/fatigue_calculator.dart';
import 'package:flutter_application_1/utils/populate_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Operations Screens/operationProfile.dart';

class OperationsDashboardScreen extends StatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  _OperationsDashboardScreenState createState() =>
      _OperationsDashboardScreenState();
}

Future<void> _updateOperationalMetrics() async {
  final firestore = FirebaseFirestore.instance;

  final criticalFlightsCount =
      (await firestore.collection('criticalFlights').get()).docs.length;
  final moderateFlightsCount =
      (await firestore.collection('moderateFlights').get()).docs.length;
  final healthyFlightsCount =
      (await firestore.collection('healthyFlights').get()).docs.length;

  await firestore.collection('operationalMetrics').doc('PIA').update({
    'criticalFlightsCount': criticalFlightsCount,
    'moderateFlightsCount': moderateFlightsCount,
    'healthyFlightsCount': healthyFlightsCount,
    'lastUpdated': FieldValue.serverTimestamp(),
  });
}

class _OperationsDashboardScreenState extends State<OperationsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _recalculateAllPilotScores();
  }

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
              .collection('flights')
              .snapshots()
              .asyncMap((snapshot) async {
            // Verify and update risk categories before showing counts
            await _verifyAndUpdateRiskCategories();

            // Then fetch the latest metrics
            return await FirebaseFirestore.instance
                .collection('operationalMetrics')
                .doc('PIA')
                .get();
          }),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong',
                    style: TextStyle(color: Colors.white)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ??
                {
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

  Future<void> _verifyAndUpdateRiskCategories() async {
    final firestore = FirebaseFirestore.instance;

    // Get all flights that need verification
    final criticalFlights = await firestore.collection('criticalFlights').get();
    final moderateFlights = await firestore.collection('moderateFlights').get();
    final healthyFlights = await firestore.collection('healthyFlights').get();

    for (var flightDoc in [
      ...criticalFlights.docs,
      ...moderateFlights.docs,
      ...healthyFlights.docs
    ]) {
      final flightData = flightDoc.data();
      final List<dynamic> pilots = flightData['pilots'];

      double highestScore = 0.0;
      bool hasRedFlags = false;

      // Check each pilot's latest scores
      for (var pilot in pilots) {
        final pilotId = pilot['pilotId'];

        // Get latest assessment
        final assessment = await firestore
            .collection('fatigueAssessments')
            .doc('${pilotId}_${flightData['flightId']}')
            .get();

        if (assessment.exists) {
          final assessmentData = assessment.data()!;
          final questions = assessmentData['questions'] as Map<String, dynamic>;

          // Check for red flags
          if (questions['alertnessLevel'] <= 2 ||
              questions['hoursSleptLast24'] <= 4 ||
              questions['sleepQuality'] <= 3 ||
              questions['stressLevel'] >= 8) {
            hasRedFlags = true;
            break;
          }

          // Get fatigue score
          final scoreDoc = await firestore
              .collection('fatigueScores')
              .doc('${pilotId}_${flightData['flightId']}')
              .get();

          if (scoreDoc.exists) {
            final score = scoreDoc.data()!['finalScore'] as double;
            if (score > highestScore) {
              highestScore = score;
            }
          }
        }
      }

      // Determine correct risk category
      String correctCategory;
      if (hasRedFlags || highestScore >= 0.7) {
        correctCategory = 'Critical';
      } else if (highestScore >= 0.5) {
        correctCategory = 'Moderate';
      } else {
        correctCategory = 'Healthy';
      }

      // Move flight to correct collection if needed
      final currentCollection = flightDoc.reference.parent.id;
      if (currentCollection != '${correctCategory.toLowerCase()}Flights') {
        // Add to correct collection
        await firestore
            .collection('${correctCategory.toLowerCase()}Flights')
            .doc(flightData['flightId'])
            .set(flightData);

        // Remove from current collection
        await flightDoc.reference.delete();

        // Update main flight document
        await firestore
            .collection('flights')
            .doc(flightData['flightId'])
            .update({'riskCategory': correctCategory});
      }
    }

    // Update operational metrics
    final criticalCount =
        (await firestore.collection('criticalFlights').count().get()).count;
    final moderateCount =
        (await firestore.collection('moderateFlights').count().get()).count;
    final healthyCount =
        (await firestore.collection('healthyFlights').count().get()).count;

    await firestore.collection('operationalMetrics').doc('PIA').update({
      'criticalFlightsCount': criticalCount,
      'moderateFlightsCount': moderateCount,
      'healthyFlightsCount': healthyCount,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
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

Future<void> _recalculateAllPilotScores() async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Get all active flights
    final flightsQuery = await firestore
        .collection('flights')
        .where('status', isEqualTo: 'Scheduled')
        .get();

    for (var flightDoc in flightsQuery.docs) {
      final flightData = flightDoc.data();
      final List<dynamic> pilots = flightData['pilots'];

      double highestScore = 0.0;
      String highestRiskCategory = 'Healthy';
      List<Map<String, dynamic>> updatedPilots = [];

      // Process each pilot in the flight
      for (var pilot in pilots) {
        final pilotId = pilot['pilotId'];
        final metricsDoc =
            await firestore.collection('pilotMetrics').doc(pilotId).get();
        final assessmentDoc = await firestore
            .collection('fatigueAssessments')
            .doc('${pilotId}_${flightDoc.id}')
            .get();

        if (metricsDoc.exists && assessmentDoc.exists) {
          final metrics = metricsDoc.data()!;
          final assessment = assessmentDoc.data()!;

          final fatigueScore = await calculatePilotFatigueScore(
              metrics, assessment, pilotId, flightDoc.id);

          // Update pilot's fatigue score
          updatedPilots.add({
            ...pilot,
            'fatigueScore': fatigueScore,
          });

          // Keep track of highest risk score
          if (fatigueScore > highestScore) {
            highestScore = fatigueScore;
            highestRiskCategory =
                FatigueCalculator.getRiskCategory(fatigueScore);
          }
        }
      }

 // Preserve existing flight data while updating
final existingFlightData = flightDoc.data()!;
final updatedFlightData = {
  ...existingFlightData,
  'riskCategory': highestRiskCategory,
  'pilots': pilots.map((pilot) => {
    'pilotId': pilot['pilotId'],
    'name': pilot['name'],
    'role': pilot['role'],
    'fatigueScore': updatedPilots.firstWhere(
      (p) => p['pilotId'] == pilot['pilotId'],
      orElse: () => pilot
    )['fatigueScore'],
  }).toList(),
};

// Update flight document
await firestore.collection('flights').doc(flightDoc.id).set(updatedFlightData);

// Update risk-specific collections
await _updateRiskSpecificCollections(
  flightDoc.id, 
  updatedFlightData,  // Pass the complete updated data
  highestRiskCategory,
  updatedFlightData['pilots'] as List<Map<String, dynamic>>
);
    }

    // Update operational metrics
    await _updateOperationalMetrics();
  } catch (e) {
    print('Error calculating fatigue scores: $e');
  }
}

Future<void> _updateRiskSpecificCollections(
    String flightId,
    Map<String, dynamic> flightData,
    String riskCategory,
    List<Map<String, dynamic>> pilots) async {
  final firestore = FirebaseFirestore.instance;
final flightInfo = {
  'flightId': flightId,
  'flightNumber': flightData['flightNumber'],
  'route': flightData['route'],
  'startTime': flightData['startTime'],
  'endTime': flightData['endTime'],
  'duration': flightData['duration'],
  'status': flightData['status'],
  'pilots': pilots.map((pilot) => {
    'pilotId': pilot['pilotId'],
    'name': pilot['name'],
    'role': pilot['role'],
    'fatigueScore': pilot['fatigueScore'],
  }).toList(),
};
  // Remove from all risk collections first
  await Future.wait([
    firestore.collection('criticalFlights').doc(flightId).delete(),
    firestore.collection('moderateFlights').doc(flightId).delete(),
    firestore.collection('healthyFlights').doc(flightId).delete(),
  ]);

  // Add to appropriate collection based on risk category
  switch (riskCategory) {
    case 'Critical':
      await firestore
          .collection('criticalFlights')
          .doc(flightId)
          .set(flightInfo);
      break;
    case 'Moderate':
      await firestore
          .collection('moderateFlights')
          .doc(flightId)
          .set(flightInfo);
      break;
    case 'Healthy':
      await firestore
          .collection('healthyFlights')
          .doc(flightId)
          .set(flightInfo);
      break;
  }
}

Future<double> calculatePilotFatigueScore(
  Map<String, dynamic> metrics,
  Map<String, dynamic> assessment,
  String pilotId,
  String flightId,
) async {
  final flightHoursWeight = FatigueCalculator.normalizeFlightHoursWeek(
      metrics['totalFlightHoursLast7Days'] ?? 0);
  final timeZoneWeight = FatigueCalculator.normalizeTimeZones(
      metrics['timeZonesCrossedLast24Hours'] ?? 0);
  final restPeriodWeight = FatigueCalculator.calculateRestPeriodScore(
      metrics['lastRestPeriodEnd'],
      assessment['questions']['hoursSleptLast24'] ?? 8);
  final flightDurationWeight = FatigueCalculator.normalizeFlightDuration(
      metrics['currentDutyPeriodDuration'] ?? 0);
  final selfAssessmentWeight =
      FatigueCalculator.normalizeSelfAssessment(assessment['questions']);

  final finalScore = FatigueCalculator.calculateFinalScore(
    flightHoursWeight: flightHoursWeight,
    timeZoneWeight: timeZoneWeight,
    restPeriodWeight: restPeriodWeight,
    flightDurationWeight: flightDurationWeight,
    selfAssessmentWeight: selfAssessmentWeight,
  );

  // Store the calculated scores
  await FirebaseFirestore.instance
      .collection('fatigueScores')
      .doc('${pilotId}_$flightId')
      .set({
    'pilotId': pilotId,
    'flightId': flightId,
    'assessmentId': '${pilotId}_$flightId',
    'dutyHourScore': flightHoursWeight,
    'timezoneScore': timeZoneWeight,
    'restPeriodScore': restPeriodWeight,
    'flightDurationScore': flightDurationWeight,
    'selfAssessmentScore': selfAssessmentWeight,
    'finalScore': finalScore,
    'riskCategory': FatigueCalculator.getRiskCategory(finalScore),
    'timestamp': FieldValue.serverTimestamp(),
  });

  return finalScore;
}
