import 'package:flutter/material.dart';

class FatigueDetailsScreen extends StatelessWidget {
  const FatigueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatigue Details'),
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
              title: 'Recent Flight Hours',
              value: '12 of 32 max',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Time Zones Crossed',
              value: '2 in last 24hrs',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Hours Since Rest',
              value: '8 of 14 max',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String value,
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
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}