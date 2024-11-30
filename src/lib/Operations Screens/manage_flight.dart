import 'package:flutter/material.dart';

class ManageFlightScreen extends StatelessWidget {
  const ManageFlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Flight'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to Reassign Pilot screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReassignPilotScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Reassign Pilot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                // Navigate to Adjust Schedule screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdjustScheduleScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Adjust Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReassignPilotScreen extends StatelessWidget {
  const ReassignPilotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement the Reassign Pilot screen logic here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reassign Pilot'),
      ),
      body: const Center(
        child: Text('Reassign Pilot Screen'),
      ),
    );
  }
}

class AdjustScheduleScreen extends StatelessWidget {
  const AdjustScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement the Adjust Schedule screen logic here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Schedule'),
      ),
      body: const Center(
        child: Text('Adjust Schedule Screen'),
      ),
    );
  }
}