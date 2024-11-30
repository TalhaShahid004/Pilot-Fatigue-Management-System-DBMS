import 'package:flutter/material.dart';

class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              title: 'Status',
              value: 'On Time',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Date',
              value: 'September 11, 2024',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Time',
              value: '10:30 - 11:45',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Flight Crew',
              value: 'Pilot: Capt. Aileen\nFirst Officer: Capt. Joe',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Aircraft',
              value: 'Boeing 737-800\nReg: N64701',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Flight Duration',
              value: '1h 15m',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Fatigue Index',
              value: '8.7',
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // // Navigate to Fatigue Details screen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => FatigueDetailsScreen(),
                      //   ),
                      // );
                      Navigator.pushNamed(context, '/fatigue_details');
                    },
                    child: const Text('Fatigue Details'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Manage Flight screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageFlightScreen(),
                        ),
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
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}

// class FatigueDetailsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Implement the Fatigue Details screen logic here
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fatigue Details'),
//       ),
//       body: const Center(
//         child: Text('Fatigue Details Screen'),
//       ),
//     );
//   }
// }

class ManageFlightScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement the Manage Flight screen logic here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Flight'),
      ),
      body: const Center(
        child: Text('Manage Flight Screen'),
      ),
    );
  }
}
