import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopping_list_app/general_providers.dart';
import 'package:shopping_list_app/repositories/custom_exception.dart';

// contains all the auth signatures that the auth implements
abstract class BaseAuthRepository {
  Stream<User?>
      get authStateChanges; // retruns stream of user from firebase auth
  Future<void> signInAnonymously(); // creates anon account
  User? getCurrentUser(); // current user or null
  Future<void> signOut();
}

// we pass in ref and ref.read so it can be accessed accross the app
final authRepositoryProvider = 
  Provider<AuthRepository>((ref) => AuthRepository(ref.read));

// allows AuthRepository to read the other providers in the app
class AuthRepository implements BaseAuthRepository {
  final Reader _read;
  const AuthRepository(this._read);

  // returns a nullable User whenever a user signs in or out
  @override
  Stream<User?> get authStateChanges =>
      _read(firebaseAuthProvider).authStateChanges();

  // creates a new anon User in firebase - if already signed in anon
  // it returns the existing anon User
  @override
  Future<void> signInAnonymously() async {
    try {
      await _read(firebaseAuthProvider).signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  User? getCurrentUser() {
    try {
      return _read(firebaseAuthProvider).currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  // first signs out current auth'd User and then logs in an anon User
  // this insures that an auth'd User is always logged in while using
  // the app (traceability)
  @override
  Future<void> signOut() async {
    try {
      await _read(firebaseAuthProvider).signOut();
      await signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
