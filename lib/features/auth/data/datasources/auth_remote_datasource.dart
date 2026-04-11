import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _auth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) throw const AuthException('Sign in failed.');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final User? firebaseUser;

      if (kIsWeb) {
        // Web: use Firebase popup — google_sign_in_web doesn't support
        // authenticate().
        final provider = GoogleAuthProvider();
        final result = await _auth.signInWithPopup(provider);
        firebaseUser = result.user;
      } else {
        // Mobile: use google_sign_in to get credential then sign in.
        final googleUser = await _googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        final result = await _auth.signInWithCredential(credential);
        firebaseUser = result.user;
      }

      if (firebaseUser == null) {
        throw const AuthException('Google sign-in failed.');
      }

      // Firestore profile fetch/create — failure is non-fatal since
      // Firebase Auth already succeeded.
      try {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }

        // First-time Google user — create profile.
        final model = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(model.toJson());

        return model;
      } on Exception {
        // Firestore unavailable — return a minimal profile from Firebase
        // Auth data so the session is not blocked.
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Google authentication failed.',
      );
    }
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) throw const AuthException('Sign up failed.');

      final model = UserModel(
        id: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(model.toJson());

      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } on Exception catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to get current user.');
    } on Exception catch (e) {
      throw ServerException('Failed to fetch user profile: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists) return null;
          return UserModel.fromFirestore(doc);
        } on Exception {
          // Firestore unavailable — return null so listeners treat it
          // as unauthenticated rather than crashing the stream.
          return null;
        }
      });
}
