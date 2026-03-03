import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      throw Exception('Unable to retrieve user information.');
    }

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found in Firestore.');
    }

    return AppUser.fromFirestore(doc);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String department,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      throw Exception('Registration failed.');
    }

    final appUser = AppUser(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: role,
      department: department.trim(),
    );

    await _firestore.collection('users').doc(uid).set(appUser.toMap());
    return appUser;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
