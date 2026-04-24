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
  String? _errorMessage;

  // ─── Getters ───
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      _status = _firebaseUser!.emailVerified ? AuthStatus.authenticated : AuthStatus.emailNotVerified;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ─── LOGIN DENGAN EMAIL (Tambahkan ini agar Login Page tidak merah) ───
  Future<bool> loginWithEmail({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;

      if (_firebaseUser != null && !_firebaseUser!.emailVerified) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _handleFirebaseAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // ─── REGISTER DENGAN EMAIL (Sesuai dengan pemanggilan di RegisterPage) ───
  Future<bool> register({required String name, required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;
      await _firebaseUser?.updateDisplayName(name); // Simpan nama user
      
      await _firebaseUser?.sendEmailVerification();
      _status = AuthStatus.emailNotVerified;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _handleFirebaseAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // ─── LOGIN GOOGLE (Tambahkan ini agar tombol Google tidak merah) ───
  Future<bool> loginWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googlesignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = "Gagal login Google";
      notifyListeners();
      return false;
    }
  }

  // ─── CEK VERIFIKASI (Untuk VerifyEmailPage) ───
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser?.emailVerified ?? false) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── RESEND EMAIL ───
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // ─── LOGOUT ───
  Future<void> signOut() async {
    await _auth.signOut();
    await _googlesignIn.signOut();
    _firebaseUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Biar konsisten dengan pemanggilan di UI
  Future<void> logout() => signOut();

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return "Email sudah terdaftar.";
      case 'user-not-found': return "Akun tidak ditemukan.";
      case 'wrong-password': return "Password salah.";
      case 'invalid-email': return "Format email salah.";
      default: return e.message ?? "Terjadi kesalahan.";
    }
  }
}