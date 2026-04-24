import 'dart:async'; // WAJIB untuk Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Sesuaikan import path dengan struktur foldermu
import 'package:pertemuan5/features/auth/presentation/providers/auth_provider.dart'; 
import 'package:pertemuan5/core/routers/app_router.dart';
import 'package:pertemuan5/features/auth/presentation/widgets/custom_button.dart';
import 'package:pertemuan5/features/auth/presentation/widgets/auth_header.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  Timer? _countdownTimer; 
  bool _resendCooldown = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    // Jalankan polling untuk cek status verifikasi secara otomatis
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Polling: cek setiap 5 detik apakah user sudah klik link di email
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      
      final auth = context.read<AuthProvider>();
      // Kita panggil fungsi checkEmailVerified yang ada di Provider
      final isVerified = await auth.checkEmailVerified();
      
      if (isVerified && mounted) {
        _timer?.cancel();
        // Jika sudah verif, pindah ke dashboard
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;

    // Panggil fungsi kirim ulang di provider
    await context.read<AuthProvider>().resendVerificationEmail();

    // Jalankan sistem Cooldown tombol
    setState(() {
      _resendCooldown = true;
      _countdown = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
          _resendCooldown = false;
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verifikasi sudah dikirim ulang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch user agar UI update jika data firebaseUser berubah
    final user = context.watch<AuthProvider>().firebaseUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthHeader(
                icon: Icons.mark_email_unread_outlined,
                title: 'Verifikasi Email Kamu',
                subtitle: 'Kami sudah mengirim link verifikasi ke email di bawah ini.',
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 24),

              // Box untuk menampilkan email user
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  user?.email ?? 'Email tidak ditemukan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 32),

              // Indikator Loading Polling
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('Menunggu konfirmasi...',
                    style: TextStyle(color: Colors.grey.shade600)),
              ]),
              const SizedBox(height: 32),

              // Tombol Kirim Ulang
              CustomButton(
                label: _resendCooldown
                    ? 'Kirim Ulang ($_countdown detik)'
                    : 'Kirim Ulang Email',
                onPressed: _resendCooldown ? null : _resendEmail,
              ),
              const SizedBox(height: 16),

              // Tombol Logout/Batal
              CustomButton(
                label: 'Ganti Akun / Logout',
                // Gunakan variant text jika ada di custom_button kamu
                onPressed: () {
                  context.read<AuthProvider>().signOut(); 
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}