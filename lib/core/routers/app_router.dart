import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../main.dart';

class AppRouter {
  static const String splash      = '/';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard   = '/dashboard';
  static const String cart        = '/cart';
  static const String checkout    = '/checkout';

  static Map<String, WidgetBuilder> get routes => {
    '/':              (_) => const SplashPage(),
    '/login':         (_) => const LoginPage(),
    '/register':      (_) => const RegisterPage(),
    '/verify-email':  (_) => const VerifyEmailPage(),
    '/dashboard':     (_) => const AuthGuard(child: DashboardPage()),
    '/cart':          (_) => const AuthGuard(child: CartPage()),
    '/checkout':      (_) => const AuthGuard(child: CheckoutPage()),
  };
}

// Bungkus halaman yang butuh autentikasi dengan AuthGuard
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.authenticated => child,           // Lanjut ke halaman
      AuthStatus.emailNotVerified =>
        const VerifyEmailPage(),                   // Redirect verifikasi
      _ => const LoginPage(),                     // Redirect login
    };
  }
}
