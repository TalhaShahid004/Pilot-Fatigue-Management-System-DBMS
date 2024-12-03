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
    final startTime = (flightData['startTime'] as Timestamp).toDate();
    
  
    String finalRiskCategory = 'Healthy';
    bool needsUpdate = false;

    // Check each pilot's latest scores and metrics
    for (var pilot in pilots) {
      final pilotId = pilot['pilotId'];

      final metricsDoc = await firestore.collection('pilotMetrics').doc(pilotId).get();

      final assessmentQuery = await firestore
          .collection('fatigueAssessments')
          .where('pilotId', isEqualTo: pilotId)
          .where('flightId', isEqualTo: flightData['flightId'])
          .limit(1)
          .get();

     
      if (metricsDoc.exists && assessmentQuery.docs.isNotEmpty) {
        final metrics = metricsDoc.data()!;
        final assessmentDoc = assessmentQuery.docs.first;
        final assessmentData = assessmentDoc.data();
        final questions = assessmentData['questions'] as Map<String, dynamic>;

        // Check critical thresholds first
if (questions['alertnessLevel'] <= 2) {
  finalRiskCategory = 'Critical';
  needsUpdate = true;
  break;
}
if (questions['hoursSleptLast24'] <= 4) {
  finalRiskCategory = 'Critical';
  needsUpdate = true;
  break;
}
if (questions['sleepQuality'] == 'Very Poor') {
  finalRiskCategory = 'Critical';
  needsUpdate = true;
  break;
}
if (questions['stressLevel'] >= 8) {
  finalRiskCategory = 'Critical';
  needsUpdate = true;
  break;
}

// Only check moderate triggers if we haven't found critical ones
if (finalRiskCategory != 'Critical') {
  
  // Rest + Duration triggers
  if (metrics['totalFlightHoursLast7Days'] > 35 && metrics['lastRestPeriodHours'] < 14) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }
  if (questions['hoursSleptLast24'] < 6 && flightData['duration'] > 6) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }

  // Timezone Impact
  if (metrics['timeZonesCrossedLast24Hours'] > 3 && metrics['lastRestPeriodHours'] < 14) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }

  // Self-Assessment Concerns
  if (questions['stressLevel'] > 7) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }
  if (questions['alertnessLevel'] < 4) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }
  if (questions['sleepQuality'] == 'Poor' && flightData['duration'] > 4) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }

  // Time of Day checks
  final hour = startTime.hour;
  final isNightFlight = hour >= 22 || hour < 6;
  final isEarlyMorning = hour >= 4 && hour < 6;

  if (isNightFlight && questions['hoursSleptLast24'] < 7) {
    finalRiskCategory = 'Moderate';
    needsUpdate = true;
  }
  
  if (isEarlyMorning && metrics['lastDutyEnd'] != null) {
    final previousDutyEnd = (metrics['lastDutyEnd'] as Timestamp).toDate();
    final previousDutyHour = previousDutyEnd.hour;
    if (previousDutyHour >= 22) {
      finalRiskCategory = 'Moderate';
      needsUpdate = true;
    }
  }
}
      }
    }

    if (needsUpdate) {
      
      // Remove from all collections first
      await Future.wait([
        firestore.collection('criticalFlights').doc(flightData['flightId']).delete(),
        firestore.collection('moderateFlights').doc(flightData['flightId']).delete(),
        firestore.collection('healthyFlights').doc(flightData['flightId']).delete(),
      ]);

      // Add to new collection
      await firestore
          .collection('${finalRiskCategory.toLowerCase()}Flights')
          .doc(flightData['flightId'])
          .set({
        ...flightData,
        'riskCategory': finalRiskCategory,
      });

      // Update main flight document
      await firestore
          .collection('flights')
          .doc(flightData['flightId'])
          .update({'riskCategory': finalRiskCategory});
      
    }
  }

  await _updateOperationalMetrics();
}
  Future<double> calculatePilotFatigueScore(
    Map<String, dynamic> metrics,
    Map<String, dynamic> assessment,
    String pilotId,
    String flightId,
  ) async {
    final questions = assessment['questions'] as Map<String, dynamic>;
    final flightDoc = await FirebaseFirestore.instance
        .collection('flights')
        .doc(flightId)
        .get();
    final flightData = flightDoc.data()!;

    final flightHoursWeight = FatigueCalculator.normalizeFlightHoursWeek(
        metrics['totalFlightHoursLast7Days'] ?? 0);
    final timeZoneWeight = FatigueCalculator.normalizeTimeZones(
        metrics['timeZonesCrossedLast24Hours'] ?? 0);
    final restPeriodWeight = FatigueCalculator.calculateRestPeriodScore(
        metrics['lastRestPeriodEnd'], questions['hoursSleptLast24'] ?? 8);
    final flightDurationWeight = FatigueCalculator.normalizeFlightDuration(
        metrics['currentDutyPeriodDuration'] ?? 0);
    final selfAssessmentWeight =
        FatigueCalculator.normalizeSelfAssessment(questions);

    final finalScore = FatigueCalculator.calculateFinalScore(
      flightHoursWeight: flightHoursWeight,
      timeZoneWeight: timeZoneWeight,
      restPeriodWeight: restPeriodWeight,
      flightDurationWeight: flightDurationWeight,
      selfAssessmentWeight: selfAssessmentWeight,
    );

    final riskCategory = FatigueCalculator.getRiskCategory(
      finalScore,
      totalFlightHoursLast7Days: metrics['totalFlightHoursLast7Days'] ?? 0,
      lastRestPeriodHours: metrics['lastRestPeriodHours'] ?? 0,
      hoursSleptLast24: questions['hoursSleptLast24'] ?? 0,
      timezoneCrossingsLast24: metrics['timeZonesCrossedLast24Hours'] ?? 0,
      selfAssessment: questions,
      scheduledFlightDuration: flightData['duration'] ?? 0,
      flightDepartureTime: (flightData['startTime'] as Timestamp).toDate(),
      previousDutyEndTime: metrics['lastDutyEnd'] != null
          ? (metrics['lastDutyEnd'] as Timestamp).toDate()
          : null,
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
      'riskCategory': riskCategory,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return finalScore;
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
          'pilots': pilots
              .map((pilot) => {
                    'pilotId': pilot['pilotId'],
                    'name': pilot['name'],
                    'role': pilot['role'],
                    'fatigueScore': updatedPilots.firstWhere(
                        (p) => p['pilotId'] == pilot['pilotId'],
                        orElse: () => pilot)['fatigueScore'],
                  })
              .toList(),
        };

// Update flight document
        await firestore
            .collection('flights')
            .doc(flightDoc.id)
            .set(updatedFlightData);

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
            'pilots': pilots
                .map((pilot) => {
                      'pilotId': pilot['pilotId'],
                      'name': pilot['name'],
                      'role': pilot['role'],
                      'fatigueScore': pilot['fatigueScore'],
                    })
                .toList(),
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

// Update risk-specific collections
        await _updateRiskSpecificCollections(
            flightDoc.id,
            updatedFlightData, // Pass the complete updated data
            highestRiskCategory,
            updatedFlightData['pilots'] as List<Map<String, dynamic>>);
      }

      // Update operational metrics
      await _updateOperationalMetrics();
    } catch (e) {
      print('Error calculating fatigue scores: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _recalculateAllPilotScores();
  }
}
