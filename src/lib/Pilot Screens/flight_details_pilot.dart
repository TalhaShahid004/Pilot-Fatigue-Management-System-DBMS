import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PilotFlightDetailsScreen extends StatelessWidget {
  const PilotFlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String flightId = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Flight Details',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('flights').doc(flightId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('Flight not found', style: TextStyle(color: Colors.white)));
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final startTime = (data['startTime'] as Timestamp).toDate();
          final endTime = (data['endTime'] as Timestamp).toDate();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['flightNumber'],
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(data['route'],
                        style: const TextStyle(color: Colors.white70, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.schedule, 'Departure',
                        DateFormat('MMM d, HH:mm').format(startTime)),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.schedule, 'Arrival',
                        DateFormat('MMM d, HH:mm').format(endTime)),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.timer, 'Duration',
                        '${data['duration']} minutes'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Crew',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...List<Map<String, dynamic>>.from(data['pilots']).map((pilot) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF2E4B61),
                                child: Text(pilot['name'][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pilot['name'],
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  Text(pilot['role'],
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('fatigueAssessments')
                      .where('flightId', isEqualTo: flightId)
                      .limit(1)
                      .get(),
                  builder: (context, assessmentSnapshot) {
                    final bool isWithin4Hours = startTime.difference(DateTime.now()).inHours <= 4;
                    final bool hasAssessment = assessmentSnapshot.hasData && 
                        assessmentSnapshot.data!.docs.isNotEmpty;

                    return Column(
                      children: [
                        ElevatedButton(
           onPressed: isWithin4Hours ? 
  () => Navigator.pushNamed(context, '/flight_assessment', arguments: flightId) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C810F),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: Text(
                            isWithin4Hours ? 'Complete Fatigue Assessment' : 
                            'Assessment available 4 hours before flight',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21384A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 16, 
                fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}