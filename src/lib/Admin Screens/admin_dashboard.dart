// import 'package:flutter/material.dart';

// class AdminDashboardScreen extends StatelessWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF141414),
//       appBar: AppBar(
//         title: const Text('Welcome, Admin'),
//         backgroundColor: const Color(0xFF141414),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildInfoCard(
//               title: 'Active Pilots',
//               value: '245',
//               color: Colors.green,
//             ),
//             const SizedBox(height: 16),
//             _buildInfoCard(
//               title: 'Active Flights',
//               value: '20',
//               color: Colors.white,
//             ),
//             const SizedBox(height: 16),
//             _buildInfoCard(
//               title: 'Critical Alerts',
//               value: '4',
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             _buildInfoCard(
//               title: 'Avg Fatigue Score',
//               value: '7.5',
//               color: Colors.yellow,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C2C),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'adjust_weights.dart';
import 'admin_reports.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Welcome, Admin'),
        backgroundColor: const Color(0xFF141414),
        actions: [
          _buildNavItem(
            title: 'Dashboard',
            onTap: () => _navigateTo(0),
          ),
          _buildNavItem(
            title: 'Reports',
            onTap: () => _navigateTo(1),
          ),
          _buildNavItem(
            title: 'Adjust Weights',
            onTap: () => _navigateTo(2),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _getCurrentScreen(),
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedIndex == _getIndexFromTitle(title)
                ? Colors.white
                : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  int _getIndexFromTitle(String title) {
    switch (title) {
      case 'Dashboard':
        return 0;
      case 'Reports':
        return 1;
      case 'Adjust Weights':
        return 2;
      default:
        return 0;
    }
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return ReportsScreen();
      case 2:
        return WeightAdjustmentScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: 'Active Pilots',
          value: '245',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Active Flights',
          value: '20',
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Critical Alerts',
          value: '4',
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Avg Fatigue Score',
          value: '7.5',
          color: Colors.yellow,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
