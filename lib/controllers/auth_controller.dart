import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopping_list_app/repositories/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(ref.read)..appStarted(),
);

// state of the auth controller may be null when the user is not logged in OR
// it can be a Firebase user when user is logged in
class AuthController extends StateNotifier<User?> {
  final Reader _read;

  StreamSubscription<User?>? _authStateChangesSubscription;

  AuthController(this._read) : super(null) {
    // subscribe to authstatechanges stream from the auth repository
    // so that the auth controller's state can be updated when any user
    // logs in or logs out
    _authStateChangesSubscription?.cancel();
    _authStateChangesSubscription = _read(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }

  // need the cancel to the subscription just in case it exists
  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  // gets the current user from firebase and if there isn't a user it
  // signs in as an anon User
  void appStarted() async {
    final user = _read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      await _read(authRepositoryProvider).signInAnonymously();
    }
  }

  void signOut() async {
    await _read(authRepositoryProvider).signOut();
  }
}
