// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  pilot,
  operations,
  admin,
  unknown
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in and determine user role
  Future<UserRole> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // First attempt to sign in
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw 'Authentication failed';
      }

      // Check admin collection first (direct document ID match)
      final adminDoc = await _firestore.collection('admins').doc(email).get();
      if (adminDoc.exists) {
        return UserRole.admin;
      }

      // Check operations collection (direct document ID match)
      final operationsDoc = await _firestore.collection('operations').doc(email).get();
      if (operationsDoc.exists) {
        return UserRole.operations;
      }

      // Check pilots collection (query by email field)
      final pilotsQuery = await _firestore
          .collection('pilots')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (pilotsQuery.docs.isNotEmpty) {
        return UserRole.pilot;
      }

      // If no matching role found, sign out and throw error
      await _auth.signOut();
      throw 'User not found in any authorized collection';

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'An error occurred. Please try again';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user email
  Future<String?> getCurrentUserEmail() async {
    return _auth.currentUser?.email;
  }

  // Get current user data from Firestore
// In auth_service.dart
Future<Map<String, dynamic>> getCurrentUserData() async {
  final user = _auth.currentUser;
  if (user == null) throw 'No user logged in';

  // Check operations collection first
  final operationsDoc = await _firestore
      .collection('operations')
      .doc(user.email)
      .get();

  if (operationsDoc.exists) {
    // Return the data and include the document ID (email) as part of the map
    return {
      'email': operationsDoc.id,  // Add the document ID as email
      ...operationsDoc.data() ?? {},
    };
  }

  // Rest of the method remains the same...
  final pilotsQuery = await _firestore
      .collection('pilots')
      .where('email', isEqualTo: user.email)
      .limit(1)
      .get();

  if (pilotsQuery.docs.isNotEmpty) {
    return pilotsQuery.docs.first.data();
  }

  throw 'User data not found';
}
// Also update the updateOperationsProfile method to use the correct collection
Future<void> updateOperationsProfile({
  required String firstName,
  required String lastName,
}) async {
  final user = _auth.currentUser;
  if (user == null) throw 'No user logged in';
  
  await _firestore.collection('operations').doc(user.email).update({
    'firstName': firstName,
    'lastName': lastName,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
  // Update pilot profile
  Future<void> updatePilotProfile({
  required String licenseNumber,
  required String experience,
  required String firstName,
  required String lastName,
  String? phoneNumber,
}) async {
  final user = _auth.currentUser;
  if (user == null) throw 'No user logged in';

  final querySnapshot = await _firestore
      .collection('pilots')
      .where('email', isEqualTo: user.email)
      .limit(1)
      .get();

  if (querySnapshot.docs.isEmpty) {
    throw 'User data not found';
  }

  await querySnapshot.docs.first.reference.update({
    'licenseNumber': licenseNumber,
    'experience': experience,
    'phoneNumber': phoneNumber,
    'firstName': firstName,
    'lastName': lastName,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<String?> getCurrentPilotId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final pilotsQuery = await _firestore
          .collection('pilots')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (pilotsQuery.docs.isNotEmpty) {
        return pilotsQuery.docs.first.get('pilotId');  // Assuming each pilot document has a pilotId field
      }
      return null;
    } catch (e) {
      print('Error getting pilot ID: $e');
      return null;
    }
  }
}


