// import 'package:flutter/material.dart';

// class WeightAdjustmentScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF141414),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Text(
//             'Weight Adjustment Screen',
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class WeightAdjustmentScreen extends StatefulWidget {
  @override
  _WeightAdjustmentScreenState createState() => _WeightAdjustmentScreenState();
}

class _WeightAdjustmentScreenState extends State<WeightAdjustmentScreen> {
  double _flightHours = 0.0;
  double _timeZonesCrossed = 0.0;
  double _hoursSinceLastRest = 0.0;
  double _flightDuration = 0.0;
  double _selfAssessment = 0.0;
  double _criticalRiskThreshold = 0.0;
  double _moderateRiskThreshold = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Weight Adjustment'),
        backgroundColor: const Color(0xFF141414),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField('Flight Hours (Last 7 Days)', _flightHours),
            _buildInputField('Time Zones Crossed', _timeZonesCrossed),
            _buildInputField('Hours Since Last Rest', _hoursSinceLastRest),
            _buildInputField('Flight Duration', _flightDuration),
            _buildInputField('Self Assessment', _selfAssessment),
            _buildInputField('Critical Risk Threshold', _criticalRiskThreshold),
            _buildInputField('Moderate Risk Threshold', _moderateRiskThreshold),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _resetToDefault,
                  child: const Text('Reset to Default'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, double value) {
    final _controller = TextEditingController(text: value.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (String newValue) {
          setState(() {
            switch (label) {
              case 'Flight Hours (Last 7 Days)':
                _flightHours = double.tryParse(newValue) ?? 0.0;
                break;
              case 'Time Zones Crossed':
                _timeZonesCrossed = double.tryParse(newValue) ?? 0.0;
                break;
              // Rest of the cases
            }
          });
        },
      ),
    );
  }

  void _saveChanges() {
    // Save the changes to the database or some other storage
    print('Saved changes:');
    print('Flight Hours: $_flightHours');
    print('Time Zones Crossed: $_timeZonesCrossed');
    print('Hours Since Last Rest: $_hoursSinceLastRest');
    print('Flight Duration: $_flightDuration');
    print('Self Assessment: $_selfAssessment');
    print('Critical Risk Threshold: $_criticalRiskThreshold');
    print('Moderate Risk Threshold: $_moderateRiskThreshold');
  }

  void _resetToDefault() {
    setState(() {
      _flightHours = 0.0;
      _timeZonesCrossed = 0.0;
      _hoursSinceLastRest = 0.0;
      _flightDuration = 0.0;
      _selfAssessment = 0.0;
      _criticalRiskThreshold = 0.0;
      _moderateRiskThreshold = 0.0;
    });
  }
}
