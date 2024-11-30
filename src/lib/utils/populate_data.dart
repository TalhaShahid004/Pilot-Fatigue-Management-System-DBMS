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
      {'routeId': 'PK1', 'flightCode': 'PK301', 'airlineId': 'PIA', 'departureAirport': 'KHI', 'arrivalAirport': 'ISB'},
      {'routeId': 'PK2', 'flightCode': 'PK302', 'airlineId': 'PIA', 'departureAirport': 'ISB', 'arrivalAirport': 'KHI'},
      {'routeId': 'PK3', 'flightCode': 'PK303', 'airlineId': 'PIA', 'departureAirport': 'KHI', 'arrivalAirport': 'LHE'},
      {'routeId': 'PK4', 'flightCode': 'PK304', 'airlineId': 'PIA', 'departureAirport': 'LHE', 'arrivalAirport': 'KHI'},
      {'routeId': 'PK5', 'flightCode': 'PK785', 'airlineId': 'PIA', 'departureAirport': 'ISB', 'arrivalAirport': 'DXB'},
      {'routeId': 'PK6', 'flightCode': 'PK786', 'airlineId': 'PIA', 'departureAirport': 'DXB', 'arrivalAirport': 'ISB'},
    ];

    for (var route in routes) {
      await _firestore.collection('flightRoutes').doc(route['routeId']).set(route);
    }
  }

  // Populate Flights
  Future<void> populateFlights() async {
    // Create flights for next 7 days
    final now = DateTime.now();
    final flights = [];

    // Morning KHI-ISB-KHI rotation
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      
      // KHI to ISB (Morning)
      flights.add({
        'flightId': 'F${i}A1',
        'routeId': 'PK1',
        'flightDate': date,
        'startTime': DateTime(date.year, date.month, date.day, 7, 0),
        'endTime': DateTime(date.year, date.month, date.day, 9, 0),
        'riskCategory': 'Healthy',  // Healthy string for now
        'status': 'Scheduled'
      });

      // ISB to KHI (Morning Return)
      flights.add({
        'flightId': 'F${i}A2',
        'routeId': 'PK2',
        'flightDate': date,
        'startTime': DateTime(date.year, date.month, date.day, 10, 0),
        'endTime': DateTime(date.year, date.month, date.day, 12, 0),
        'riskCategory': 'Healthy',  
        'status': 'Scheduled'
      });

      // KHI to DXB (Evening)
      flights.add({
        'flightId': 'F${i}B1',
        'routeId': 'PK5',
        'flightDate': date,
        'startTime': DateTime(date.year, date.month, date.day, 18, 0),
        'endTime': DateTime(date.year, date.month, date.day, 20, 30),
        'riskCategory': 'Healthy',  
        'status': 'Scheduled'
      });
    }

    for (var flight in flights) {
      await _firestore.collection('flights').doc(flight['flightId']).set(flight);
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
    
    // Count flights by risk category
    final flightsRef = firestore.collection('flights');
    final criticalCount = (await flightsRef.where('riskCategory', isEqualTo: 'Critical').get()).size;
    final moderateCount = (await flightsRef.where('riskCategory', isEqualTo: 'Moderate').get()).size;
    final healthyCount = (await flightsRef.where('riskCategory', isEqualTo: 'Healthy').get()).size;

    // Update the metrics
    await firestore.collection('operationalMetrics').doc('PIA').set({
      'criticalFlightsCount': criticalCount,
      'moderateFlightsCount': moderateCount,
      'healthyFlightsCount': healthyCount,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}