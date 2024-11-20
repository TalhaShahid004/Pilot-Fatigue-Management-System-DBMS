import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// For VERY NEXT FLIGHT
class NextFlightDetails {
  final int flightId;
  final String routeCode;
  final String flightTime;
  final String startTime;
  // final String gate;
  final String date;

  NextFlightDetails({
    required this.flightId,
    required this.routeCode,
    required this.flightTime,
    required this.startTime,
    // required this.gate,
    required this.date,
  });
}

// for VERY NEXT FLIGHT
Future<NextFlightDetails?> fetchNextFlightDetails(String username) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getUpcomingFlightDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return NextFlightDetails(
        flightId: data[0]['flight_id'],
        routeCode: data[0]['route_code'],
        flightTime: '${data[0]['flight_time']} min',
        startTime: data[0]['starting_time'],
        // gate: 'Gate B2', // Replace with actual gate info if available
        date: data[0]['flight_date'], // Replace with actual date
      );
    } else {
      print('Failed to fetch flight details');
      return null;
    }
  } catch (e) {
    print('Error fetching flight details: $e');
    return null;
  }
}

// for LATER FLIGHTS
class UpcomingFlightDetails {
  final List<int> flightIds;
  final List<String> routeCodes;
  final List<String> flightTimes;
  final List<String> startTimes;
  // final List<String> gates;
  final List<String> dates;

  UpcomingFlightDetails({
    required this.flightIds,
    required this.routeCodes,
    required this.flightTimes,
    required this.startTimes,
    // required this.gates,
    required this.dates,
  });
}

// for LATER FLIGHTS
Future<UpcomingFlightDetails?> fetchUpcomingFlightDetails(
    String username) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getUpcomingFlightDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      if (data.isNotEmpty) {
        data = data.sublist(1);
      }

      final List<int> flightIds = [];
      final List<String> routeCodes = [];
      final List<String> flightTimes = [];
      final List<String> startTimes = [];
      // final List<String> gates;
      final List<String> dates = [];

      for (int i = 0; i < data.length; i++) {
        flightIds.add(data[i]['flight_id']);
        routeCodes.add(data[i]['route_code']);
        flightTimes.add('${data[i]['flight_time']} min');
        startTimes.add(data[i]['starting_time']);
        // gate: 'Gate B2', // Replace with actual gate info if available
        dates.add(data[i]['flight_date']); // Replace with actual date
      }
      return UpcomingFlightDetails(
        flightIds: flightIds,
        routeCodes: routeCodes,
        flightTimes: flightTimes,
        startTimes: startTimes,
        // gate: 'Gate B2', // Replace with actual gate info if available
        dates: dates, // Replace with actual date
      );
    } else {
      print('Failed to fetch flight details');
      return null;
    }
  } catch (e) {
    print('Error fetching flight details: $e');
    return null;
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // added this:
    // Extract arguments from ModalRoute
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final username = args?['username'] ?? 'Unknown';
    final password = args?['password'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pilot Dashboard - Welcome $username',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildNextFlightCard(username),
              _buildUpcomingFlightsSection(username),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextFlightCard(String username) {
    return FutureBuilder<NextFlightDetails?>(
        future: fetchNextFlightDetails(
            username), // Assuming this function fetches the details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while waiting for the data
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // Handle any errors
          } else if (snapshot.hasData) {
            final nfd = snapshot.data; // The fetched NextFlightDetails object
            if (nfd == null) {
              return const Center(child: Text('No upcoming flight available'));
            }
            // Proceed to build the UI with the fetched data
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 62, top: 24),
                      child: Row(
                        children: [
                          Icon(Icons.flight,
                              color: Color(0xFFE6E6E6), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Next Flight',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nfd.flightId.toString(), // 'GF203',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            nfd.routeCode, //'DXB→DOH',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nfd.flightTime, //'1hr 15m',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nfd.startTime, //'10:30',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Text(
                              //   'Gate B2',
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.w200,
                              //     color: Colors.white.withOpacity(0.8),
                              //   ),
                              // ),
                              const SizedBox(height: 4),
                              Text(
                                nfd.date, //'September 11, 2024',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle fatigue assessment
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C810F),
                            minimumSize: const Size(196, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Complete Fatigue Assessment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // A fallback widget in case none of the conditions match
          return const Center(child: Text('Unexpected state'));
        });
  }

  Widget _buildUpcomingFlightsSection(String username) {
    return FutureBuilder<UpcomingFlightDetails?>(
        future: fetchUpcomingFlightDetails(
            username), // Assuming this function fetches the details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while waiting for the data
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // Handle any errors
          } else if (snapshot.hasData) {
            final nfd = snapshot.data; // The fetched NextFlightDetails object
            if (nfd == null) {
              return const Center(child: Text('No upcoming flight available'));
            }
            // Proceed to build the UI with the fetched data
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF9CABBA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Upcoming Flights',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap:
                            true, // Ensures the list takes only the required height
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents scrolling inside
                        itemCount: nfd.flightIds.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildUpcomingFlightCard(
                              flightNumber: nfd.flightIds[index].toString(),
                              route: nfd.routeCodes[index],
                              duration: nfd.flightTimes[index],
                              time: nfd.startTimes[index],
                              date: nfd.dates[index],
                            ),
                          );
                        }),
                    //   _buildUpcomingFlightCard(
                    //       flightNumber: nfd.flightIds[0].toString(), //'GF204',
                    //       route: nfd.routeCodes[0], //'LAX→SFO',
                    //       duration: nfd.flightTimes[0], // '4hr',
                    //       // gate: // 'Gate A4',
                    //       time: nfd.startTimes[0], // '12:00',
                    //       date: nfd.dates[0] // 'September 13, 2024',
                    //       ),
                    // const SizedBox(height: 16),
                    // _buildUpcomingFlightCard(
                    //   flightNumber: nfd.flightIds[1].toString(), //'GF204',
                    //       route: nfd.routeCodes[1], //'LAX→SFO',
                    //       duration: nfd.flightTimes[1], // '4hr',
                    //       // gate: // 'Gate A4',
                    //       time: nfd.startTimes[1], // '12:00',
                    //       date: nfd.dates[1] // 'September 13, 2024',
                    // ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Unexpected state'));
        });
  }

  Widget _buildUpcomingFlightCard({
    required String flightNumber,
    required String route,
    required String duration,
    // required String gate,
    required String time,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9CABBA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                flightNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                route,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text(
                  //   gate,
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w200,
                  //     color: Colors.white.withOpacity(0.8),
                  //   ),
                  // ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
