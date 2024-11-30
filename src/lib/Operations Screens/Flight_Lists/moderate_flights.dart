import 'package:flutter/material.dart';

class ModerateRiskFlightsScreen extends StatelessWidget {
  const ModerateRiskFlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderate Risk Flights'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the /flight_risk screen
            Navigator.popUntil(context, ModalRoute.withName('/flight_risk'));
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moderate Risk Flights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildFlightCard(
                      flightNumber: 'GF203',
                      route: 'DXB→DOH',
                      flightRisk: 8.7,
                      onTap: () {
                        // Navigate to the details screen for this flight
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlightDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFlightCard(
                      flightNumber: 'GF204',
                      route: 'LAX→SFO',
                      flightRisk: 8.1,
                      onTap: () {
                        // Navigate to the details screen for this flight
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlightDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFlightCard(
                      flightNumber: 'GF205',
                      route: 'KHI→DXB',
                      flightRisk: 9.1,
                      onTap: () {
                        // Navigate to the details screen for this flight
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlightDetailsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightCard({
    required String flightNumber,
    required String route,
    required double flightRisk,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF21384A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flightNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  route,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'FI: $flightRisk',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          'Flight Details Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}