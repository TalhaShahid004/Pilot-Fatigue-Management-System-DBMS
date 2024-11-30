import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/populate_data.dart';

class OperationsDashboardScreen extends StatelessWidget {
  const OperationsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Flight Risk Overview'),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final populator = DataPopulationUtil();
        await populator.populateAll();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data populated successfully')),
        );
      },
    ),
  ],
),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRiskButton(
                label: 'Critical',
                flights: '14 flights',
                change: '5% increase',
                onPressed: () {
                  // Handle critical risk button press
                  Navigator.pushNamed(context, '/critical_risk_flights');
                },
              ),
              const SizedBox(height: 16),
              _buildRiskButton(
                label: 'Moderate',
                flights: '8 flights',
                change: '4% increase',
                onPressed: () {
                  // Handle moderate risk button press
                  Navigator.pushNamed(context, '/moderate_risk_flights');
                },
              ),
              const SizedBox(height: 16),
              _buildRiskButton(
                label: 'Healthy',
                flights: '3 flights',
                change: '2% decrease',
                onPressed: () {
                  // Handle healthy risk button press
                  Navigator.pushNamed(context, '/healthy_risk_flights');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskButton({
    required String label,
    required String flights,
    required String change,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getRiskColor(label),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                flights,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                change,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String label) {
    switch (label) {
      case 'Critical':
        return const Color(0xFFFF4D4D);
      case 'Moderate':
        return const Color(0xFFFFA500);
      case 'Healthy':
        return const Color(0xFF00C853);
      default:
        return Colors.grey;
    }
  }
}
