import 'package:flutter/material.dart';

class FlightAssessmentScreen extends StatefulWidget {
  const FlightAssessmentScreen({super.key});

  @override
  State<FlightAssessmentScreen> createState() => _FlightAssessmentScreenState();
}

class _FlightAssessmentScreenState extends State<FlightAssessmentScreen> {
  int alertLevel = 4;
  int sleepHours = 0;
  String sleepQuality = 'Excellent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlertSection(),
              const SizedBox(height: 16),
              _buildSleepSection(),
              const SizedBox(height: 16),
              _buildSleepQualitySection(),
              const Spacer(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How alert are you now?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: alertLevel.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: (value) {
            setState(() {
              alertLevel = value.toInt();
            });
          },
          activeColor: Colors.blue,
          inactiveColor: const Color(0xFF9CABBA),
        ),
      ],
    );
  }

  Widget _buildSleepSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How many hours of sleep did you have in the last 24 hours?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepHours = 8;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepHours == 8 ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('8 hours'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepHours = 6;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepHours == 6 ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('6-8 hours'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepHours = 4;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepHours == 4 ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('4-6 hours'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepHours = 4;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepHours < 4 ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('< 4 hours'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you rate your sleep quality?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepQuality = 'Excellent';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepQuality == 'Excellent' ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('Excellent'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepQuality = 'Good';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepQuality == 'Good' ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('Good'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepQuality = 'Fair';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepQuality == 'Fair' ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('Fair'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepQuality = 'Poor';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepQuality == 'Poor' ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('Poor'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sleepQuality = 'Very Poor';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sleepQuality == 'Very Poor' ? Colors.blue : const Color(0xFF2C2C2C),
                ),
                child: const Text('Very Poor'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle form submission
          print('Alert Level: $alertLevel');
          print('Sleep Hours: $sleepHours');
          print('Sleep Quality: $sleepQuality');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C810F),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}