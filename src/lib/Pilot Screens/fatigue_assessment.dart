import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class FlightAssessmentScreen extends StatefulWidget {
  const FlightAssessmentScreen({super.key});

  @override
  State<FlightAssessmentScreen> createState() => _FlightAssessmentScreenState();
}

class _FlightAssessmentScreenState extends State<FlightAssessmentScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String flightId;
  String? assignmentId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      flightId = ModalRoute.of(context)?.settings.arguments as String;
      await _fetchAssignmentId();
    });
  }

  Future<void> _fetchAssignmentId() async {
    try {
      final userEmail = await _authService.getCurrentUserEmail();
      if (userEmail == null) return;

      final assignmentQuery = await _firestore
          .collection('flightAssignments')
          .where('flightId', isEqualTo: flightId)
          .where('pilotId', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (assignmentQuery.docs.isNotEmpty) {
        setState(() {
          assignmentId = assignmentQuery.docs.first.id;
        });
      }
    } catch (e) {
      print('Error fetching assignment ID: $e');
    }
  }
  
  // Updated state variables with normalized scales
  double alertnessLevel = 4.0; // Scale 1-7
  double sleepQualityValue = 5.0;   // Scale 1-10
  double stressLevel = 5.0;    // Scale 1-10
  double hoursSleptLast24 = 7.0; // Scale 0-12
  bool isSubmitting = false;

  // Helper method to get alertness level description
  String getAlertnessDescription(double value) {
    if (value <= 1) return 'Extremely Fatigued - Struggling to stay awake';
    if (value <= 2) return 'Very Fatigued - Minimal alertness';
    if (value <= 3) return 'Fatigued - Reduced alertness';
    if (value <= 4) return 'Moderate - Average alertness';
    if (value <= 5) return 'Alert - Good attention level';
    if (value <= 6) return 'Very Alert - High attention level';
    return 'Extremely Alert - Peak alertness';
  }

  // Helper method to get stress level description
  String getStressDescription(double value) {
    if (value <= 2) return 'Very Low - Completely relaxed';
    if (value <= 4) return 'Low - Minimal stress';
    if (value <= 6) return 'Moderate - Normal stress levels';
    if (value <= 8) return 'High - Elevated stress';
    return 'Very High - Extreme stress';
  }

  Future<void> _submitAssessment() async {
    if (isSubmitting) return;
    
    setState(() {
      isSubmitting = true;
    });

    try {
      final userEmail = await _authService.getCurrentUserEmail();
      if (userEmail == null) throw Exception('No user logged in');

      // Create fatigue assessment document
     // Convert sleep quality value to string category before storing
      String sleepQualityCategory = sleepQualityValue >= 8 ? 'Excellent' :
                                   sleepQualityValue >= 6 ? 'Good' :
                                   sleepQualityValue >= 4 ? 'Fair' :
                                   sleepQualityValue >= 2 ? 'Poor' : 'Very Poor';

if (assignmentId == null) {
  throw Exception('No assignment ID found for this flight');
}

await _firestore.collection('fatigueAssessments').doc(assignmentId).set({
  'pilotId': userEmail,
  'flightId': flightId,
        'score': _calculateFinalScore(),
        'timestamp': FieldValue.serverTimestamp(),
        'questions': {
          'sleepQuality': sleepQualityCategory,
          'alertnessLevel': alertnessLevel,
          'stressLevel': stressLevel,
          'hoursSleptLast24': hoursSleptLast24,
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment submitted successfully'))
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting assessment: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  double _calculateFinalScore() {
    // Normalize all scores to 0-10 scale and take weighted average
    double normalizedAlertness = (alertnessLevel / 7) * 10;
    double normalizedSleep = (hoursSleptLast24 / 12) * 10;
    
    return (normalizedAlertness * 0.3 + 
            sleepQualityValue * 0.3 + 
            (10 - stressLevel) * 0.2 + // Invert stress level
            normalizedSleep * 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Fatigue Assessment',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssessmentCard(
                title: 'Current Alertness Level',
                description: 'How alert do you feel right now?',
                value: alertnessLevel,
                min: 1,
                max: 7,
                divisions: 6,
                valueDescription: getAlertnessDescription(alertnessLevel),
                onChanged: (value) => setState(() => alertnessLevel = value),
              ),
              const SizedBox(height: 20),
              _buildAssessmentCard(
                title: 'Hours of Sleep',
                description: 'How many hours did you sleep in the last 24 hours?',
                value: hoursSleptLast24,
                min: 0,
                max: 12,
                divisions: 24,
                valueDescription: '${hoursSleptLast24.toStringAsFixed(1)} hours',
                onChanged: (value) => setState(() => hoursSleptLast24 = value),
              ),
              const SizedBox(height: 20),
             _buildAssessmentCard(
                title: 'Sleep Quality',
                description: 'Rate the quality of your last sleep',
                value: sleepQualityValue,
                min: 1,
                max: 10,
                divisions: 9,
                valueDescription: sleepQualityValue >= 8 ? 'Excellent' :
                                sleepQualityValue >= 6 ? 'Good' :
                                sleepQualityValue >= 4 ? 'Fair' :
                                sleepQualityValue >= 2 ? 'Poor' : 'Very Poor',
                onChanged: (value) => setState(() => sleepQualityValue = value),
              ),
              const SizedBox(height: 20),
              _buildAssessmentCard(
                title: 'Stress Level',
                description: 'Rate your current stress level',
                value: stressLevel,
                min: 1,
                max: 10,
                divisions: 9,
                valueDescription: getStressDescription(stressLevel),
                onChanged: (value) => setState(() => stressLevel = value),
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueDescription,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveColor: const Color(0xFF9CABBA),
          ),
          Text(
            valueDescription,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitAssessment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C810F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFF1C810F).withOpacity(0.5),
        ),
        child: isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit Assessment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}