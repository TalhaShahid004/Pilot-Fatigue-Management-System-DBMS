// lib/utils/fatigue_calculator.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FatigueCalculator {
  static double normalizeFlightHoursWeek(num hours) {
    // More aggressive scaling for flight hours
    if (hours >= 80) return 1.0; // Maximum risk at 80+ hours
    return (hours / 80).clamp(0.0, 1.0);
  }

  static double normalizeTimeZones(num zones) {
    // More impactful timezone changes
    if (zones >= 6) return 1.0; // Maximum risk at 6+ zones
    return (zones / 6).clamp(0.0, 1.0);
  }

  static double calculateRestPeriodScore(Timestamp? lastRest, double hoursSlept) {
    if (lastRest == null) return 1.0;
    
    final hoursSinceRest = DateTime.now().difference(lastRest.toDate()).inHours;
    
    // Critical thresholds
    if (hoursSinceRest >= 16 || hoursSlept <= 4) return 1.0;
    
    final restTimingScore = (hoursSinceRest / 16).clamp(0.0, 1.0);
    final sleepScore = (1 - (hoursSlept / 10)).clamp(0.0, 1.0);
    
    return (restTimingScore * 0.7 + sleepScore * 0.3).clamp(0.0, 1.0);
  }

  static double normalizeFlightDuration(num duration) {
    if (duration >= 12) return 1.0; // Maximum risk at 12+ hours
    return (duration / 12).clamp(0.0, 1.0);
  }

static double normalizeSelfAssessment(Map<String, dynamic> assessment) {
    final alertness = (assessment['alertnessLevel'] as num);
    final stress = (assessment['stressLevel'] as num);
    
    // Convert sleep quality string to number
    final sleepQualityMap = {
      'Excellent': 9.0,
      'Good': 7.0,
      'Fair': 5.0,
      'Poor': 3.0,
      'Very Poor': 1.0
    };
    final sleepQuality = sleepQualityMap[assessment['sleepQuality']] ?? 5.0;
    
    // Critical thresholds
    if (alertness <= 3 || stress >= 8 || sleepQuality <= 3) {
      return 1.0;
    }
    
    final alertnessScore = (7 - alertness) / 7;
    final stressScore = stress / 10;
    final sleepScore = (10 - sleepQuality) / 10;
    
    return (alertnessScore * 0.4 + stressScore * 0.4 + sleepScore * 0.2).clamp(0.0, 1.0);
  }

  static double calculateFinalScore({
    required double flightHoursWeight,
    required double timeZoneWeight,
    required double restPeriodWeight,
    required double flightDurationWeight,
    required double selfAssessmentWeight,
  }) {
    final score = (0.30 * flightHoursWeight) +
           (0.25 * timeZoneWeight) +
           (0.20 * restPeriodWeight) +
           (0.15 * flightDurationWeight) +
           (0.10 * selfAssessmentWeight);
    
    return score.clamp(0.0, 1.0);
  }

static String getRiskCategory(
  double score, {
  num? totalFlightHoursLast7Days,
  num? lastRestPeriodHours,
  num? hoursSleptLast24,
  num? timezoneCrossingsLast24,
  Map<String, dynamic>? selfAssessment,
  num? scheduledFlightDuration,
  DateTime? flightDepartureTime,
  DateTime? previousDutyEndTime,
}) {
  // If advanced parameters are provided, check triggers
  if (totalFlightHoursLast7Days != null &&
      lastRestPeriodHours != null &&
      hoursSleptLast24 != null &&
      timezoneCrossingsLast24 != null &&
      selfAssessment != null &&
      scheduledFlightDuration != null &&
      flightDepartureTime != null) {
    
    // Check Critical Triggers
    if (hasCriticalTriggers(
      totalFlightHoursLast7Days: totalFlightHoursLast7Days,
      lastRestPeriodHours: lastRestPeriodHours,
      hoursSleptLast24: hoursSleptLast24,
      timezoneCrossingsLast24: timezoneCrossingsLast24,
      selfAssessment: selfAssessment,
    )) {
      return 'Critical';
    }

    // Check Moderate Triggers
    if (_hasModerateTriggers(
      totalFlightHoursLast7Days: totalFlightHoursLast7Days,
      lastRestPeriodHours: lastRestPeriodHours,
      hoursSleptLast24: hoursSleptLast24,
      timezoneCrossingsLast24: timezoneCrossingsLast24,
      selfAssessment: selfAssessment,
      scheduledFlightDuration: scheduledFlightDuration,
      flightDepartureTime: flightDepartureTime,
      previousDutyEndTime: previousDutyEndTime,
    )) {
      return 'Moderate';
    }
  }

  // Fallback to score-based categorization
  if (score >= 0.7) return 'Critical';
  if (score >= 0.5) return 'Moderate';
  return 'Healthy';
}
static bool hasCriticalTriggers({
  required num totalFlightHoursLast7Days,
  required num lastRestPeriodHours,
  required num hoursSleptLast24,
  required num timezoneCrossingsLast24,
  required Map<String, dynamic> selfAssessment,
}) {
  // Rest + Duration triggers
  if (totalFlightHoursLast7Days > 45 && lastRestPeriodHours < 12) return true;
  if (hoursSleptLast24 < 5) return true;

  // Timezone Impact
  if (timezoneCrossingsLast24 > 4 && lastRestPeriodHours < 12) return true;

  // Self-Assessment Red Flags
  final stressLevel = selfAssessment['stressLevel'] as num;
  final alertnessLevel = selfAssessment['alertnessLevel'] as num;
  
  if (stressLevel > 8) return true;
  if (alertnessLevel < 3) return true;

  return false;
}

static bool _hasModerateTriggers({
  required num totalFlightHoursLast7Days,
  required num lastRestPeriodHours,
  required num hoursSleptLast24,
  required num timezoneCrossingsLast24,
  required Map<String, dynamic> selfAssessment,
  required num scheduledFlightDuration,
  required DateTime flightDepartureTime,
  DateTime? previousDutyEndTime,
}) {
  // Rest + Duration triggers
  if (totalFlightHoursLast7Days > 35 && lastRestPeriodHours < 14) return true;
  if (hoursSleptLast24 < 6 && scheduledFlightDuration > 6) return true;

  // Timezone Impact
  if (timezoneCrossingsLast24 > 3 && lastRestPeriodHours < 14) return true;

  // Self-Assessment Concerns
  final stressLevel = selfAssessment['stressLevel'] as num;
  final alertnessLevel = selfAssessment['alertnessLevel'] as num;
  final sleepQuality = _getSleepQualityScore(selfAssessment['sleepQuality']);

  if (stressLevel > 7) return true;
  if (alertnessLevel < 4) return true;
  if (sleepQuality < 4 && scheduledFlightDuration > 4) return true;

  // Time of Day checks
  final hour = flightDepartureTime.hour;
  final isNightFlight = hour >= 22 || hour < 6;
  final isEarlyMorning = hour >= 4 && hour < 6;

  if (isNightFlight && hoursSleptLast24 < 7) return true;
  
  if (isEarlyMorning && previousDutyEndTime != null) {
    final previousDutyHour = previousDutyEndTime.hour;
    if (previousDutyHour >= 22) return true;
  }

  return false;
}

static num _getSleepQualityScore(String quality) {
  final sleepQualityMap = {
    'Excellent': 9.0,
    'Good': 7.0,
    'Fair': 5.0,
    'Poor': 3.0,
    'Very Poor': 1.0
  };
  return sleepQualityMap[quality] ?? 5.0;
}

  Future<void> updateFlightRiskCategory(String flightId, String newCategory, Map<String, dynamic> flightData) async {
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
}