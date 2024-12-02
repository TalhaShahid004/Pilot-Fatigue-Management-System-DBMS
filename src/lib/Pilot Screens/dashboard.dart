import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Pilot%20Screens/profile.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/Pilot%20Screens/flight_details_pilot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? nextFlight;
  List<Map<String, dynamic>> upcomingFlights = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPilotFlights();
  }

  Future<void> _loadPilotFlights() async {
    try {
      final userEmail = await _authService
          .getCurrentUserEmail(); // Get email instead of pilotId
      if (userEmail == null) {
        print('No user email found');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get current timestamp
      final now = DateTime.now();
      print('Fetching assignments for pilot: $userEmail'); // Debug print

      // Query flight assignments for this pilot using email
      final assignmentsQuery = await _firestore
          .collection('flightAssignments')
          .where('pilotId', isEqualTo: userEmail) // Use email as pilotId
          .get();

      print('Found ${assignmentsQuery.docs.length} assignments'); // Debug print

      // Get all flight IDs assigned to this pilot
      final flightIds =
          assignmentsQuery.docs.map((doc) => doc.get('flightId')).toList();

      if (flightIds.isEmpty) {
        print('No flight assignments found');
        setState(() {
          nextFlight = null;
          upcomingFlights = [];
          isLoading = false;
        });
        return;
      }

      print('Flight IDs: $flightIds'); // Debug print

      // Get flights
      final flightsQuery = await _firestore
          .collection('flights')
          .where(FieldPath.documentId, whereIn: flightIds)
          .orderBy('startTime')
          .get();

      print('Found ${flightsQuery.docs.length} flights'); // Debug print

      final flights = flightsQuery.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      // Separate into next flight and upcoming flights
      final futureFlights = flights.where((flight) {
        final startTime = (flight['startTime'] as Timestamp).toDate();
        return startTime.isAfter(now);
      }).toList();

      setState(() {
        if (futureFlights.isNotEmpty) {
          nextFlight = futureFlights.first;
          upcomingFlights = futureFlights.skip(1).toList();
        } else {
          nextFlight = null;
          upcomingFlights = [];
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading flights: $e');
      setState(() {
        isLoading = false;
        nextFlight = null;
        upcomingFlights = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Pilot Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNextFlightCard(context),
              _buildUpcomingFlightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF21384A),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2194F2),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: _authService.getCurrentUserEmail(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Pilot',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white24),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await _authService.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextFlightCard(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (nextFlight == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No upcoming flights scheduled',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final startTime = (nextFlight!['startTime'] as Timestamp).toDate();
    final endTime = (nextFlight!['endTime'] as Timestamp).toDate();
    final duration = nextFlight!['duration'] as int;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/flight_details_pilot',
        arguments: nextFlight!['id'],
      ),
      child: Padding(
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
                    Icon(Icons.flight, color: Color(0xFFE6E6E6), size: 24),
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
                      nextFlight!['flightNumber'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      nextFlight!['route'],
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
                          '${duration ~/ 60}h ${duration % 60}m',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${DateFormat('HH:mm').format(endTime)} - ${DateFormat('HH:mm').format(startTime)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMMM d, yyyy').format(startTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('fatigueAssessments')
                    .where('pilotId', isEqualTo: nextFlight!['pilotId'])
                    .where('assignmentId',
                        isEqualTo: nextFlight!['assignmentId'])
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  final bool isWithin4Hours =
                      startTime.difference(DateTime.now()).inHours <= 4;
                  final bool hasAssessment =
                      snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                  return Column(
                    children: [
                      if (isWithin4Hours)
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/flight_assessment',
                                arguments: nextFlight!['id'] as String,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C810F),
                                minimumSize: const Size(196, 38),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Fatigue Assessment',
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingFlightsSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcomingFlights.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No additional upcoming flights',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

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
            ...upcomingFlights.map((flight) {
              final startTime = (flight['startTime'] as Timestamp).toDate();
              final duration = flight['duration'] as int;
              final flightId =
                  flight['id']; // Get the flight ID from the document

              return _buildUpcomingFlightCard(
                flightNumber: flight['flightNumber'],
                route: flight['route'],
                duration: '${duration ~/ 60}h ${duration % 60}m',
                time: DateFormat('HH:mm').format(startTime),
                date: DateFormat('MMMM d, yyyy').format(startTime),
                pilots: flight['pilots'] as List<dynamic>,
                flightId: flightId, // Pass the flight ID
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingFlightCard({
    required String flightNumber,
    required String route,
    required String duration,
    required String time,
    required String date,
    required List<dynamic> pilots,
    required String flightId,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/flight_details_pilot',
        arguments: flightId,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9CABBA)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flightNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              route,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  } 
}
