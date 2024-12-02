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
    final alertness = (assessment['alertnessLevel'] as num);
    final stress = (assessment['stressLevel'] as num);
    final hoursSlept = (assessment['hoursSleptLast24'] as num);
    final sleepQuality = (assessment['sleepQuality'] as num);
    
    // Critical conditions that should immediately raise red flags
    if (alertness <= 2 || // Very low alertness
        stress >= 8 || // High stress
        hoursSlept <= 4 || // Insufficient sleep
        sleepQuality <= 3) { // Poor sleep quality
        return 1.0; // Maximum risk score
    }
    
    // Normal calculation for non-critical cases
    final alertnessScore = (7 - alertness) / 7; // Inverse because lower alertness = higher risk
    final stressScore = stress / 10;
    final sleepScore = (10 - sleepQuality) / 10;
    
    return (alertnessScore * 0.4 + stressScore * 0.3 + sleepScore * 0.3).clamp(0.0, 1.0);
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