// lib/utils/populate_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DataPopulationUtil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Populate Airports
  Future<void> populateAirports() async {
    final airports = {
      'KHI': {'airportName': 'Jinnah International Airport', 'city': 'Karachi', 'country': 'Pakistan', 'utcOffset': 5},
      'ISB': {'airportName': 'Islamabad International Airport', 'city': 'Islamabad', 'country': 'Pakistan', 'utcOffset': 5},
      'LHE': {'airportName': 'Allama Iqbal International Airport', 'city': 'Lahore', 'country': 'Pakistan', 'utcOffset': 5},
      'DXB': {'airportName': 'Dubai International Airport', 'city': 'Dubai', 'country': 'UAE', 'utcOffset': 4},
      'LHR': {'airportName': 'London Heathrow Airport', 'city': 'London', 'country': 'UK', 'utcOffset': 0},
    };

    for (var entry in airports.entries) {
      await _firestore.collection('airports').doc(entry.key).set(entry.value);
    }
  }

  // Populate Flight Routes
  Future<void> populateFlightRoutes() async {
    final routes = [
      {'routeId': 'PK1', 'flightCode': 'PK301', 'airlineId': 'PIA', 'departureAirport': 'KHI', 'arrivalAirport': 'ISB', 'duration': 120},
      {'routeId': 'PK2', 'flightCode': 'PK302', 'airlineId': 'PIA', 'departureAirport': 'ISB', 'arrivalAirport': 'KHI', 'duration': 120},
      {'routeId': 'PK3', 'flightCode': 'PK303', 'airlineId': 'PIA', 'departureAirport': 'KHI', 'arrivalAirport': 'LHE', 'duration': 90},
      {'routeId': 'PK4', 'flightCode': 'PK304', 'airlineId': 'PIA', 'departureAirport': 'LHE', 'arrivalAirport': 'KHI', 'duration': 90},
      {'routeId': 'PK5', 'flightCode': 'PK785', 'airlineId': 'PIA', 'departureAirport': 'ISB', 'arrivalAirport': 'DXB', 'duration': 210},
      {'routeId': 'PK6', 'flightCode': 'PK786', 'airlineId': 'PIA', 'departureAirport': 'DXB', 'arrivalAirport': 'ISB', 'duration': 210},
    ];

    for (var route in routes) {
      await _firestore.collection('flightRoutes').doc(route['routeId'] as String?).set(route);
    }
  }

DateTime calculateEndTime(DateTime startTime, String departureAirport, String arrivalAirport, int durationMinutes) {
    // Get UTC offsets from the airports data structure
    final Map<String, int> airportOffsets = {
      'KHI': 5,
      'ISB': 5,
      'LHE': 5,
      'DXB': 4,
      'LHR': 0,
    };
    
    // Calculate end time in departure timezone
    DateTime endTimeUTC = startTime.add(Duration(minutes: durationMinutes));
    
    // Adjust for destination timezone
    int destOffset = airportOffsets[arrivalAirport] ?? 0;
    int srcOffset = airportOffsets[departureAirport] ?? 0;
    int offsetDiff = destOffset - srcOffset;
    
    return endTimeUTC.add(Duration(hours: offsetDiff));
}

  // Populate Flights
 Future<void> populateFlights() async {
    final now = DateTime.now();
    final flights = [];
    final criticalFlights = [];
    final moderateFlights = [];
    final healthyFlights = [];

    // Sample pilot data
    final pilots = [
      {'pilotId': 'P1', 'name': 'John Smith', 'role': 'Captain', 'fatigueScore': 75},
      {'pilotId': 'P2', 'name': 'Sarah Johnson', 'role': 'Co-Pilot', 'fatigueScore': 82},
      {'pilotId': 'P3', 'name': 'Mike Brown', 'role': 'Captain', 'fatigueScore': 65},
      {'pilotId': 'P4', 'name': 'Lisa Davis', 'role': 'Co-Pilot', 'fatigueScore': 70},
    ];

    // Risk categories to rotate through
    final riskCategories = ['Critical', 'Moderate', 'Healthy'];
    int riskIndex = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      
      // Create three flights per day with different routes
     final dailyFlights = [
    {
      'flightId': 'F${i}A1',
      'flightNumber': 'PK301',
      'route': 'KHI→ISB',
      'startTime': DateTime(date.year, date.month, date.day, 7, 0),
      'endTime': calculateEndTime(
        DateTime(date.year, date.month, date.day, 7, 0),
        'KHI',
        'ISB',
        120  // 2 hours = 120 minutes
      ),
      'duration': 120,
      'pilots': [
        pilots[0],
        pilots[1],
      ],
      'status': 'Scheduled',
    },
    {
      'flightId': 'F${i}A2',
      'flightNumber': 'PK302',
      'route': 'ISB→KHI',
      'startTime': DateTime(date.year, date.month, date.day, 10, 0),
      'endTime': calculateEndTime(
        DateTime(date.year, date.month, date.day, 10, 0),
        'ISB',
        'KHI',
        120  // 2 hours = 120 minutes
      ),
      'duration': 120,
      'pilots': [
        pilots[2],
        pilots[3],
      ],
      'status': 'Scheduled',
    },
    {
      'flightId': 'F${i}B1',
      'flightNumber': 'PK785',
      'route': 'ISB→DXB',
      'startTime': DateTime(date.year, date.month, date.day, 18, 0),
      'endTime': calculateEndTime(
        DateTime(date.year, date.month, date.day, 18, 0),
        'ISB',
        'DXB',
        210  // 3.5 hours = 210 minutes
      ),
      'duration': 210,
      'pilots': [
        pilots[0],
        pilots[3],
      ],
      'status': 'Scheduled',
    },
];
      // Distribute flights to risk categories
      for (var j = 0; j < dailyFlights.length; j++) {
        final flight = dailyFlights[j];
        final riskCategory = riskCategories[(riskIndex + j) % 3];
        
        // Add to main flights collection
        flights.add({
          ...flight,
          'riskCategory': riskCategory,
        });

        // Add to specific risk category collection
        switch (riskCategory) {
          case 'Critical':
            criticalFlights.add(flight);
            break;
          case 'Moderate':
            moderateFlights.add(flight);
            break;
          case 'Healthy':
            healthyFlights.add(flight);
            break;
        }
      }
      
      riskIndex++;
    }

    // Populate main flights collection
    for (var flight in flights) {
      await _firestore.collection('flights').doc(flight['flightId']).set(flight);
    }

    // Populate risk-specific collections
    for (var flight in criticalFlights) {
      await _firestore.collection('criticalFlights').doc(flight['flightId']).set(flight);
    }
    for (var flight in moderateFlights) {
      await _firestore.collection('moderateFlights').doc(flight['flightId']).set(flight);
    }
    for (var flight in healthyFlights) {
      await _firestore.collection('healthyFlights').doc(flight['flightId']).set(flight);
    }

  
  }


  // Populate Flight Assignments
  Future<void> populateFlightAssignments() async {
    final pilots = ['pilot1@gmail.com', 'pilot2@gmail.com', 'pilot3@gmail.com'];
    final assignments = [];
    int assignmentCounter = 0;

    // Get all flights
    final flightDocs = await _firestore.collection('flights').get();
    
    for (var flightDoc in flightDocs.docs) {
      final flightData = flightDoc.data();
      final flightId = flightDoc.id;
      
      // Assign two pilots to each flight
      final pilot1Index = assignmentCounter % 3;
      final pilot2Index = (assignmentCounter + 1) % 3;
      
      assignments.add({
        'assignmentId': 'A${assignmentCounter}A',
        'pilotId': pilots[pilot1Index],
        'flightId': flightId,
        'role': 'Captain',
        'status': 'Assigned'
      });

      assignments.add({
        'assignmentId': 'A${assignmentCounter}B',
        'pilotId': pilots[pilot2Index],
        'flightId': flightId,
        'role': 'Co-Pilot',
        'status': 'Assigned'
      });

      assignmentCounter++;
    }

    for (var assignment in assignments) {
      await _firestore.collection('flightAssignments')
          .doc(assignment['assignmentId'])
          .set(assignment);
    }
  }

  // Populate everything
  Future<void> populateAll() async {
    await populateAirports();
    await populateFlightRoutes();
    await populateFlights();
    await populateFlightAssignments();
    await updateOperationalMetrics();
  }   

Future<void> updateOperationalMetrics() async {
    final firestore = FirebaseFirestore.instance;
    
    // Count flights in each risk category collection
    final criticalCount = (await firestore.collection('criticalFlights').get()).size;
    final moderateCount = (await firestore.collection('moderateFlights').get()).size;
    final healthyCount = (await firestore.collection('healthyFlights').get()).size;

    // Update the metrics
    await firestore.collection('operationalMetrics').doc('PIA').set({
      'criticalFlightsCount': criticalCount,
      'moderateFlightsCount': moderateCount,
      'healthyFlightsCount': healthyCount,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

}