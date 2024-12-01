import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String flightId = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Flight Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('criticalFlights')
            .doc(flightId)
            .snapshots(),
        builder: (context, criticalSnapshot) {
          if (criticalSnapshot.hasError) {
            return const Center(
              child: Text('Something went wrong', style: TextStyle(color: Colors.white)),
            );
          }

          if (criticalSnapshot.hasData && criticalSnapshot.data!.exists) {
            return _buildFlightDetails(
              context, 
              criticalSnapshot.data!, 
              flightId,
              'Critical'
            );
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('moderateFlights')
                .doc(flightId)
                .snapshots(),
            builder: (context, moderateSnapshot) {
              if (moderateSnapshot.hasData && moderateSnapshot.data!.exists) {
                return _buildFlightDetails(
                  context, 
                  moderateSnapshot.data!, 
                  flightId,
                  'Moderate'
                );
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('healthyFlights')
                    .doc(flightId)
                    .snapshots(),
                builder: (context, healthySnapshot) {
                  if (healthySnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!healthySnapshot.hasData || !healthySnapshot.data!.exists) {
                    return const Center(
                      child: Text('Flight not found', style: TextStyle(color: Colors.white)),
                    );
                  }

                  return _buildFlightDetails(
                    context, 
                    healthySnapshot.data!, 
                    flightId,
                    'Healthy'
                  );
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
    final pilots = List<Map<String, dynamic>>.from(flightData['pilots'] ?? []);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              title: 'Status',
              value: flightData['status'] ?? 'N/A',
              color: _getStatusColor(flightData['status']),
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Flight',
              value: '${flightData['flightNumber']} (${flightData['route']})',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Date & Time',
              value: _formatDateTime(startTime, endTime),
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Flight Duration',
              value: '${flightData['duration']} minutes',
            ),
            const SizedBox(height: 16),
            _buildPilotsSection(pilots),
            const SizedBox(height: 16),
            _buildRiskSection(pilots, riskCategory),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/fatigue_details',
                        arguments: flightData['flightId'],
                      );
                    },
                    child: const Text('Fatigue Details'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/manage_flight',
                        arguments: flightData['flightId'],
                      );
                    },
                    child: const Text('Manage Flight'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPilotsSection(List<Map<String, dynamic>> pilots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flight Crew',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ...pilots.map((pilot) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '${pilot['role']}: ${pilot['name']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildRiskSection(List<Map<String, dynamic>> pilots, String riskCategory) {
    double averageScore = 0;
    if (pilots.isNotEmpty) {
      final scores = pilots.map((p) => p['fatigueScore'] as num).toList();
      averageScore = scores.reduce((a, b) => a + b) / scores.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Risk Assessment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor(riskCategory),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                riskCategory,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FI: ${averageScore.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
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
}