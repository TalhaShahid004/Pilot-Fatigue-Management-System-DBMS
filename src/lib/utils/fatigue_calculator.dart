// lib/utils/fatigue_calculator.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FatigueCalculator {
  static double normalizeFlightHoursWeek(num hours) {
    // Normalize 0-100 hours to 0-1
    final normalized = hours / 100;
    return normalized.clamp(0.0, 1.0);
  }

  static double normalizeTimeZones(num zones) {
    // Normalize 0-8 timezone crosses to 0-1
    final normalized = zones / 8;
    return normalized.clamp(0.0, 1.0);
  }

  static double calculateRestPeriodScore(Timestamp? lastRest, double hoursSlept) {
    if (lastRest == null) return 1.0;
    
    final hoursSinceRest = DateTime.now().difference(lastRest.toDate()).inHours;
    
    final restTimingScore = (24 - hoursSinceRest.clamp(0, 24)) / 24;
    final sleepScore = hoursSlept / 12;
    
    return 1 - ((restTimingScore * 0.6 + sleepScore * 0.4).clamp(0.0, 1.0));
  }

  static double normalizeFlightDuration(num duration) {
    final normalized = duration / 16;
    return normalized.clamp(0.0, 1.0);
  }

  static double normalizeSelfAssessment(Map<String, dynamic> assessment) {
    final alertness = (assessment['alertnessLevel'] as num) / 7;
    final stress = (assessment['stressLevel'] as num) / 10;
    final sleepQuality = (assessment['sleepQuality'] as num) / 10;
    
    return 1 - ((alertness * 0.4 + (1 - stress) * 0.3 + sleepQuality * 0.3).clamp(0.0, 1.0));
  }

  static double calculateFinalScore({
    required double flightHoursWeight,
    required double timeZoneWeight,
    required double restPeriodWeight,
    required double flightDurationWeight,
    required double selfAssessmentWeight,
  }) {
    return (0.30 * flightHoursWeight) +
           (0.25 * timeZoneWeight) +
           (0.20 * restPeriodWeight) +
           (0.15 * flightDurationWeight) +
           (0.10 * selfAssessmentWeight);
  }

  static String getRiskCategory(double score) {
    if (score >= 0.7) return 'Critical';
    if (score >= 0.5) return 'Moderate';
    return 'Healthy';
  }
}