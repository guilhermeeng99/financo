import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInException;

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
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
  Future<UserModel> signInWithGoogle() async {
    try {
      final User? firebaseUser;

      if (kIsWeb) {
        // Web: use Firebase popup.
        final result = await _auth.signInWithPopup(GoogleAuthProvider());
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

        // First-time Google user (mobile) — create profile.
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
    } on GoogleSignInException catch (e) {
      throw AuthException(
        e.description ?? 'Google sign-in was cancelled.',
      );
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // On Web GoogleSignIn.initialize() is intentionally skipped (Firebase's
      // signInWithPopup owns the GSI lifecycle), so calling
      // _googleSignIn.signOut() throws StateError and would prevent the
      // Firebase sign-out from running — leaving the UI stuck.
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } on Object {
          // Google sign-out failure is non-fatal — the user may not have
          // signed in via Google. Catch Object (not Exception) so future
          // Error-typed failures from the SDK don't leak past this guard.
        }
      }
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
      if (doc.exists) return UserModel.fromFirestore(doc);

      // Authenticated user without Firestore profile (e.g. first-time
      // Google sign-in) — create it now.
      final model = UserModel(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(model.toJson());
      return model;
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
          if (doc.exists) return UserModel.fromFirestore(doc);
        } on Exception {
          // Firestore unavailable — fall through to minimal profile.
        }
        // Return a minimal profile from Firebase Auth data so
        // the stream never emits null for an authenticated user.
        return UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
      });
}
