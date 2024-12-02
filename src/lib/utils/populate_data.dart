// lib/utils/populate_data.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class DataPopulationUtil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Populate Airports
  Future<void> populateAirports() async {
    final airports = {
      'KHI': {
        'airportName': 'Jinnah International Airport',
        'city': 'Karachi',
        'country': 'Pakistan',
        'utcOffset': 5
      },
      'ISB': {
        'airportName': 'Islamabad International Airport',
        'city': 'Islamabad',
        'country': 'Pakistan',
        'utcOffset': 5
      },
      'LHE': {
        'airportName': 'Allama Iqbal International Airport',
        'city': 'Lahore',
        'country': 'Pakistan',
        'utcOffset': 5
      },
      'DXB': {
        'airportName': 'Dubai International Airport',
        'city': 'Dubai',
        'country': 'UAE',
        'utcOffset': 4
      },
      'LHR': {
        'airportName': 'London Heathrow Airport',
        'city': 'London',
        'country': 'UK',
        'utcOffset': 0
      },
    };

    for (var entry in airports.entries) {
      await _firestore.collection('airports').doc(entry.key).set(entry.value);
    }
  }

  // Populate Flight Routes
  Future<void> populateFlightRoutes() async {
    final routes = [
      {
        'routeId': 'PK1',
        'flightCode': 'PK301',
        'airlineId': 'PIA',
        'departureAirport': 'KHI',
        'arrivalAirport': 'ISB',
        'duration': 120
      },
      {
        'routeId': 'PK2',
        'flightCode': 'PK302',
        'airlineId': 'PIA',
        'departureAirport': 'ISB',
        'arrivalAirport': 'KHI',
        'duration': 120
      },
      {
        'routeId': 'PK3',
        'flightCode': 'PK303',
        'airlineId': 'PIA',
        'departureAirport': 'KHI',
        'arrivalAirport': 'LHE',
        'duration': 90
      },
      {
        'routeId': 'PK4',
        'flightCode': 'PK304',
        'airlineId': 'PIA',
        'departureAirport': 'LHE',
        'arrivalAirport': 'KHI',
        'duration': 90
      },
      {
        'routeId': 'PK5',
        'flightCode': 'PK785',
        'airlineId': 'PIA',
        'departureAirport': 'ISB',
        'arrivalAirport': 'DXB',
        'duration': 210
      },
      {
        'routeId': 'PK6',
        'flightCode': 'PK786',
        'airlineId': 'PIA',
        'departureAirport': 'DXB',
        'arrivalAirport': 'ISB',
        'duration': 210
      },
    ];

    for (var route in routes) {
      await _firestore
          .collection('flightRoutes')
          .doc(route['routeId'] as String?)
          .set(route);
    }
  }

  DateTime calculateEndTime(DateTime startTime, String departureAirport,
      String arrivalAirport, int durationMinutes) {
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

    // Fetch real pilot data from Firebase
    final pilotDocs = await _firestore.collection('pilots').get();
    final pilots = await Future.wait(pilotDocs.docs.map((doc) async {
      return {
        'pilotId': doc.data()['email'],
        'name': '${doc.data()['firstName']} ${doc.data()['lastName']}',
        'role': 'Captain', // Will be assigned dynamically
      };
    }));

    // Risk categories to rotate through
    final riskCategories = ['Critical', 'Moderate', 'Healthy'];
    int riskIndex = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));

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
              120),
          'duration': 120,
          'pilots': [
            {...pilots[0], 'role': 'Captain'},
            {...pilots[1], 'role': 'Co-Pilot'},
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
              120),
          'duration': 120,
          'pilots': [
            {...pilots[2], 'role': 'Captain'},
            {...pilots[3], 'role': 'Co-Pilot'},
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
              210),
          'duration': 210,
          'pilots': [
            {...pilots[0], 'role': 'Captain'},
            {...pilots[3], 'role': 'Co-Pilot'},
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
        final flightCopy = Map<String, dynamic>.from(flight);
        switch (riskCategory) {
          case 'Critical':
            criticalFlights.add(flightCopy);
            break;
          case 'Moderate':
            moderateFlights.add(flightCopy);
            break;
          case 'Healthy':
            healthyFlights.add(flightCopy);
            break;
        }
      }

      riskIndex++;
    }

    // Populate main flights collection
    for (var flight in flights) {
      await _firestore
          .collection('flights')
          .doc(flight['flightId'])
          .set(flight);
    }

    // Populate risk-specific collections
    for (var flight in criticalFlights) {
      await _firestore
          .collection('criticalFlights')
          .doc(flight['flightId'])
          .set(flight);
    }
    for (var flight in moderateFlights) {
      await _firestore
          .collection('moderateFlights')
          .doc(flight['flightId'])
          .set(flight);
    }
    for (var flight in healthyFlights) {
      await _firestore
          .collection('healthyFlights')
          .doc(flight['flightId'])
          .set(flight);
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
      await _firestore
          .collection('flightAssignments')
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
    await populatePilotData();
    await updateOperationalMetrics();
  }

  Future<void> populatePilotData() async {
  // Update: Include all 4 pilots in the initial array
  final pilots = [
    'pilot1@gmail.com',
    'pilot2@gmail.com',
    'pilot3@gmail.com',
    'pilot4@gmail.com'  // Ensure 4th pilot is included
  ];
  final now = DateTime.now();

  // Populate pilot metrics for all pilots
  for (var pilotId in pilots) {
    await _firestore.collection('pilotMetrics').doc(pilotId).set({
      'totalFlightHoursLast7Days': 20 + Random().nextInt(11),
      'totalFlightHoursLast28Days': 80 + Random().nextInt(21),
      'timeZonesCrossedLast24Hours': Random().nextInt(3),
      'lastRestPeriodEnd': now.subtract(Duration(hours: Random().nextInt(12))),
      'currentDutyPeriodStart': now.subtract(Duration(hours: Random().nextInt(6))),
    });
  }

  // Populate duty periods for all pilots
  int dutyCounter = 1;
  for (var pilotId in pilots) {  // Will now include 4th pilot
    for (int i = 0; i < 5; i++) {
      final startTime = now.subtract(Duration(days: i, hours: Random().nextInt(12)));
      final duration = 8 + Random().nextInt(4);
      
      await _firestore.collection('dutyPeriods').doc('D$dutyCounter').set({
        'pilotId': pilotId,
        'startTime': startTime,
        'endTime': startTime.add(Duration(hours: duration)),
        'totalHours': duration,
        'dutyType': Random().nextBool() ? 'Flight Duty' : 'Ground Duty',
        'status': 'Completed'
      });
      dutyCounter++;
    }
  }

  // Populate rest periods for all pilots
  int restCounter = 1;
  for (var pilotId in pilots) {  // Will now include 4th pilot
    for (int i = 0; i < 5; i++) {
      final startTime = now.subtract(Duration(days: i + 1));
      final duration = 10 + Random().nextInt(4);
      
      await _firestore.collection('restPeriods').doc('R$restCounter').set({
        'pilotId': pilotId,
        'restType': Random().nextBool() ? 'Daily Rest' : 'Extended Rest',
        'restLocation': Random().nextBool() ? 'Home Base' : 'Outstation',
        'startTime': startTime,
        'endTime': startTime.add(Duration(hours: duration)),
        'totalHours': duration,
        'minimumHours': 10,
        'status': 'Completed'
      });
      restCounter++;
    }
  }

  // Update: Modified fatigue scores generation to ensure all pilots are covered
  final flightDocs = await _firestore.collection('flights').get();
  int scoreCounter = 1;
  
  for (var flightDoc in flightDocs.docs) {
    final flightData = flightDoc.data();
    final flightId = flightDoc.id;
    
    // Extract pilots from flight data to ensure all assigned pilots get scores
    if (flightData.containsKey('pilots') && flightData['pilots'] is List) {
      final flightPilots = (flightData['pilots'] as List).cast<Map<String, dynamic>>();
      
      for (var pilotData in flightPilots) {
        final pilotId = pilotData['pilotId'];
        
        final dutyHourScore = 70 + Random().nextInt(21);
        final timezoneScore = 75 + Random().nextInt(16);
        final restPeriodScore = 80 + Random().nextInt(16);
        final flightDurationScore = 75 + Random().nextInt(16);
        final selfAssessmentScore = 70 + Random().nextInt(21);

        final finalScore = ((dutyHourScore * 0.2 +
            timezoneScore * 0.2 +
            restPeriodScore * 0.2 +
            flightDurationScore * 0.2 +
            selfAssessmentScore * 0.2).round());

        String riskCategory;
        if (finalScore >= 85) riskCategory = 'Low';
        else if (finalScore >= 70) riskCategory = 'Moderate';
        else riskCategory = 'High';

        await _firestore.collection('fatigueScores').doc('S$scoreCounter').set({
          'pilotId': pilotId,
          'flightId': flightId,
          'assessmentId': 'A${scoreCounter}_${pilotId}',  // Generate unique assessment ID
          'dutyHourScore': dutyHourScore,
          'timezoneScore': timezoneScore,
          'restPeriodScore': restPeriodScore,
          'flightDurationScore': flightDurationScore,
          'selfAssessmentScore': selfAssessmentScore,
          'finalScore': finalScore,
          'riskCategory': riskCategory,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        scoreCounter++;
      }
    }
  }
}

  Future<void> updateOperationalMetrics() async {
    final firestore = FirebaseFirestore.instance;

    // Count flights in each risk category collection
    final criticalCount =
        (await firestore.collection('criticalFlights').get()).size;
    final moderateCount =
        (await firestore.collection('moderateFlights').get()).size;
    final healthyCount =
        (await firestore.collection('healthyFlights').get()).size;

    // Update the metrics
    await firestore.collection('operationalMetrics').doc('PIA').set({
      'criticalFlightsCount': criticalCount,
      'moderateFlightsCount': moderateCount,
      'healthyFlightsCount': healthyCount,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
