import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googlesignIn = GoogleSignIn();

  // ─── State ───
  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;

  // ─── Getters ───
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  // ─── Constructor ───
  // Penting: Agar saat aplikasi dibuka, dia langsung cek apakah user sudah login
  AuthProvider() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ─── Register dengan Email & Password ───
  Future<void> registerWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners(); // Memberitahu UI untuk menampilkan loading spinner

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;
      
      // Cek apakah email perlu verifikasi
      if (_firebaseUser != null && !_firebaseUser!.emailVerified) {
        await _firebaseUser!.sendEmailVerification();
        _status = AuthStatus.emailNotVerified;
      } else {
        _status = AuthStatus.authenticated;
      }

    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _handleFirebaseAuthError(e);
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = "Terjadi kesalahan sistem.";
    } finally {
      notifyListeners(); // Update UI setelah proses selesai
    }
  }

  // Helper untuk pesan error yang lebih manusiawi
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email sudah terdaftar.";
      case 'invalid-email':
        return "Format email salah.";
      case 'weak-password':
        return "Password terlalu lemah.";
      default:
        return e.message ?? "Gagal melakukan registrasi.";
    }
  }

  // ─── Logout ───
  Future<void> signOut() async {
    await _auth.signOut();
    await _googlesignIn.signOut();
    _firebaseUser = null;
    _backendToken = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}