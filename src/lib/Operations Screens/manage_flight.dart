import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageFlightScreen extends StatelessWidget {
  final String flightId;
  final Map<String, dynamic> flightData;

  const ManageFlightScreen({
    super.key,
    required this.flightId,
    required this.flightData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Manage Flight',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...flightData['pilots']
                .map((pilot) => _buildPilotReassignCard(
                      context,
                      pilot,
                    ))
                .toList(),
            const SizedBox(height: 24.0),
            _buildActionCard(
              context,
              'Adjust Schedule',
              Icons.schedule,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdjustScheduleScreen(
                    flightId: flightId,
                    currentStartTime:
                        (flightData['startTime'] as Timestamp).toDate(),
                    currentEndTime:
                        (flightData['endTime'] as Timestamp).toDate(),
                    currentStatus: flightData['status'],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPilotReassignCard(
      BuildContext context, Map<String, dynamic> pilot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: _buildActionCard(
        context,
        'Reassign ${pilot['role']}:\n${pilot['name']}',
        Icons.person_outline,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReassignPilotScreen(
              flightId: flightId,
              currentPilotId: pilot['pilotId'],
              role: pilot['role'],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: const Color(0xFF21384A),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class ReassignPilotScreen extends StatelessWidget {
  final String flightId;
  final String currentPilotId;
  final String role;

  const ReassignPilotScreen({
    super.key,
    required this.flightId,
    required this.currentPilotId,
    required this.role,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Reassign Pilot'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pilots').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading pilots',
                    style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pilots = snapshot.data!.docs
              .where(
                  (doc) => doc.id != currentPilotId) // Filter out current pilot
              .toList();

          if (pilots.isEmpty) {
            return const Center(
              child: Text(
                'No other pilots available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pilots.length,
            itemBuilder: (context, index) {
              final pilot = pilots[index].data() as Map<String, dynamic>;
              final pilotId = pilots[index].id;

              return Card(
                color: const Color(0xFF21384A),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2E4B61),
                    child: Text(
                      pilot['firstName'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${pilot['firstName']} ${pilot['lastName']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Experience: ${pilot['experience']} years',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  onTap: () => _reassignPilot(context, pilotId, pilot),
                ),
              );
            },
          );
        },
      ),
    );
  }

 Future<void> _reassignPilot(BuildContext context, String newPilotId,
    Map<String, dynamic> pilotData) async {
  try {
    // Start a batch write
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Get the flight assignments
    QuerySnapshot assignmentSnapshot = await FirebaseFirestore.instance
        .collection('flightAssignments')
        .where('flightId', isEqualTo: flightId)
        .where('pilotId', isEqualTo: currentPilotId)
        .get();

    // Update flight assignment
    if (assignmentSnapshot.docs.isNotEmpty) {
      batch.update(assignmentSnapshot.docs.first.reference, {
        'pilotId': newPilotId,
        'status': 'Assigned'
      });
    }

    // Get the flight document
    DocumentReference flightRef = FirebaseFirestore.instance
        .collection('flights')
        .doc(flightId);
    
    DocumentSnapshot flightDoc = await flightRef.get();

    if (flightDoc.exists) {
      Map<String, dynamic> flightData = flightDoc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> pilots = List<Map<String, dynamic>>.from(flightData['pilots']);
      
      int pilotIndex = pilots.indexWhere((p) => p['pilotId'] == currentPilotId);

      if (pilotIndex != -1) {
        pilots[pilotIndex] = {
          'pilotId': newPilotId,
          'name': '${pilotData['firstName']} ${pilotData['lastName']}',
          'role': role,
          'fatigueScore': null
        };

        batch.update(flightRef, {'pilots': pilots});
      }
    }

    // Commit the batch
    await batch.commit();

    if (context.mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reassigning pilot: $e')),
      );
    }
  }
}
    }

class AdjustScheduleScreen extends StatefulWidget {
  final String flightId;
  final DateTime currentStartTime;
  final DateTime currentEndTime;
  final String currentStatus;

  const AdjustScheduleScreen({
    super.key,
    required this.flightId,
    required this.currentStartTime,
    required this.currentEndTime,
    required this.currentStatus,
  });

  @override
  State<AdjustScheduleScreen> createState() => _AdjustScheduleScreenState();
}

class _AdjustScheduleScreenState extends State<AdjustScheduleScreen> {
  late DateTime selectedDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late String status;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.currentStartTime;
    startTime = TimeOfDay.fromDateTime(widget.currentStartTime);
    endTime = TimeOfDay.fromDateTime(widget.currentEndTime);
    status = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Adjust Schedule',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flight Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF21384A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSectionButton(
                      title: 'Date',
                      value:
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                      icon: Icons.calendar_today,
                      onTap: _selectDate,
                    ),
                    const Divider(height: 1, color: Color(0xFF2E4B61)),
                    _buildSectionButton(
                      title: 'Start Time',
                      value: startTime.format(context),
                      icon: Icons.access_time,
                      onTap: () => _selectTime(true),
                    ),
                    const Divider(height: 1, color: Color(0xFF2E4B61)),
                    _buildSectionButton(
                      title: 'End Time',
                      value: endTime.format(context),
                      icon: Icons.access_time,
                      onTap: () => _selectTime(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Flight Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF21384A),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF21384A),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    items: ['Scheduled', 'InProgress', 'Completed', 'Canceled']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(value),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          status = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _updateSchedule,
                  child: const Text(
                    'Update Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionButton({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate() async {
    // Ensure initialDate is not before firstDate
    DateTime initialDate = selectedDate;
    DateTime firstDate = DateTime.now();
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              surface: Color(0xFF21384A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _updateSchedule() async {
    try {
      final DateTime newStartTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final DateTime newEndTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      await FirebaseFirestore.instance
          .collection('flights')
          .doc(widget.flightId)
          .update({
        'startTime': Timestamp.fromDate(newStartTime),
        'endTime': Timestamp.fromDate(newEndTime),
        'status': status,
      });

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating schedule: $e')),
        );
      }
    }
  }
}
