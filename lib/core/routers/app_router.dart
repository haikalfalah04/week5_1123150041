import 'package:flutter/material.dart';
// Import semua halaman kamu di sini
import 'package:pertemuan5/features/auth/presentation/pages/login_page.dart';
import 'package:pertemuan5/features/auth/presentation/pages/register_page.dart';
import 'package:pertemuan5/features/auth/presentation/pages/verify_email_page.dart';

class AppRouter {
  // Nama-nama Rute (Static Constants)
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';

  // Map yang menghubungkan nama rute dengan Widget halamannya
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    verifyEmail: (context) => const VerifyEmailPage(),
    // dashboard: (context) => const DashboardPage(), // Buka jika sudah ada
  };
}