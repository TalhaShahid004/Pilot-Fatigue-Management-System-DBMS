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

  static String getRiskCategory(double score) {
    if (score >= 0.7) return 'Critical';
    if (score >= 0.5) return 'Moderate';
    return 'Healthy';
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