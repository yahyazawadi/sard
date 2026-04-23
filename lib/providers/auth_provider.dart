import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '313420731986-drmk2ueaidtk20b58djs3e13ak3uv3f4.apps.googleusercontent.com',
  );

  User? _user;
  bool _isGuest = false;
  bool _isLoading = false;
  bool _hasSeenOnboarding = false;

  User? get user => _user;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _user != null || _isGuest;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  final SharedPreferences prefs;

  AuthProvider(this.prefs) {
    _init();
  }

  void _init() {
    _isGuest = prefs.getBool('isGuest') ?? false;
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      // If user logs in physically, override guest state.
      if (user != null) {
        if (_isGuest) {
          _isGuest = false;
          prefs.setBool('isGuest', false);
        }
        // Mark onboarding complete on any successful auth
        if (!_hasSeenOnboarding) {
          _completeOnboardingSilent();
        }
      }
      notifyListeners();
    });
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    await prefs.setBool('hasSeenOnboarding', true);
    notifyListeners();
  }

  void _completeOnboardingSilent() {
    _hasSeenOnboarding = true;
    prefs.setBool('hasSeenOnboarding', true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signInAsGuest() async {
    _setLoading(true);
    try {
      await prefs.setBool('isGuest', true);
      _isGuest = true;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    print(
      '!!! Login attempt — email: "$email", password length: ${password.length}',
    );
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Reload to get fresh emailVerified from server
      await result.user?.reload();
      _user = _auth.currentUser;
      print('!!! Login SUCCESS — emailVerified: ${_user?.emailVerified}');
    } catch (e) {
      final code = e is FirebaseAuthException ? e.code : 'unknown';
      print('!!! Login FAILED — code: $code');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Called after applyActionCode to refresh emailVerified state
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);

      // Update local _user with new display name natively without waiting for next stream tick
      await cred.user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final gsi.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final gsi.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint(
        "Google ID Token: ${googleAuth.idToken != null ? 'RECEIVED' : 'NULL'}",
      );
      debugPrint(
        "Google Access Token: ${googleAuth.accessToken != null ? 'RECEIVED' : 'NULL'}",
      );

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      debugPrint("Firebase Sign-In with Google: SUCCESS");
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendSignInLinkToEmail(String email) async {
    _setLoading(true);
    try {
      final acs = _getActionCodeSettings();

      await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);

      // Save email locally to complete sign-in later
      await prefs.setString('emailForSignIn', email);
    } catch (e) {
      debugPrint("Send Sign-In Link Error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmailLink(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);
    print('!!! Starting registration for: $email');
    try {
      try {
        // 1. Create account
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user?.updateDisplayName(name);
        print('!!! Account created for: $email');

        // Send email verification link
        final acs = _getActionCodeSettings();
        await cred.user?.sendEmailVerification(acs);
        print('!!! Verification email sent to: $email');

        // Sign out so user must verify before logging in
        await _auth.signOut();
        print('!!! Signed out after registration.');
        return;
      } catch (e) {
        // If account already exists, we proceed with the magic link flow (for recovery/login)
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          print(
            '!!! Account already exists. Sending magic link for sign-in/recovery.',
          );
        } else {
          rethrow;
        }
      }

      // 3. Send the magic link for existing accounts (or recovery)
      final acs = _getActionCodeSettings();
      print('!!! Sending Magic Link to: $email');
      await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);
      print('!!! Magic Link sent successfully.');

      await prefs.setString('emailForSignIn', email);
    } catch (e) {
      print('!!! Register With Email Link Error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmResetAndLogin(
    String oobCode,
    String email,
    String newPassword,
  ) async {
    _setLoading(true);
    print('!!! Confirming password reset and logging in for: $email');
    try {
      // 1. Confirm the reset
      await _auth.confirmPasswordReset(code: oobCode, newPassword: newPassword);
      print('!!! Password reset confirmed.');

      // 2. Sign in immediately
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: newPassword,
      );
      print('!!! Immediate login successful.');
    } catch (e) {
      print('!!! Confirm Reset and Login Error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  ActionCodeSettings _getActionCodeSettings() {
    return ActionCodeSettings(
      // Use the project's base URL instead of the internal auth path
      url: 'https://flutter-ai-playground-96a06.firebaseapp.com/home',
      handleCodeInApp: true,
      androidPackageName: 'com.example.sarad',
      androidInstallApp: true,
      androidMinimumVersion: '24',
    );
  }

  Future<void> signInWithEmailLink(String email, String emailLink) async {
    _setLoading(true);
    print('!!! Attempting signInWithEmailLink for email: $email');
    try {
      if (_auth.isSignInWithEmailLink(emailLink)) {
        print('!!! Link is a valid Firebase Sign-In link.');
        final UserCredential userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );
        print(
          '!!! Magic link sign-in SUCCESS. User: ${userCredential.user?.email}',
        );
        // Clear the saved email
        await prefs.remove('emailForSignIn');
      } else {
        print('!!! Error: Link is NOT a valid Firebase Sign-In link.');
        throw Exception("Invalid sign-in link.");
      }
    } catch (e) {
      print('!!! signInWithEmailLink Error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String? getEmailForSignIn() {
    return prefs.getString('emailForSignIn');
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await prefs.setBool('isGuest', false);
      _isGuest = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fullReset() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await prefs.clear();
      _isGuest = false;
      _hasSeenOnboarding = false;
      _user = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}
