import 'package:flutter/material.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/theme/app_colors.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _triggerAuth();
  }

  Future<void> _triggerAuth() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    final success = await BiometricAuthService.instance.authenticate(
      reason: 'Desbloquea ROCEEL Operativo',
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isAuthenticating = false;
        _error = 'No se pudo verificar tu identidad';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: AppColors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'ROCEEL Operativo',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aplicación bloqueada',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_isAuthenticating)
                    const CircularProgressIndicator(color: AppColors.white)
                  else
                    ElevatedButton.icon(
                      onPressed: _triggerAuth,
                      icon: const Icon(Icons.fingerprint_rounded, size: 28),
                      label: const Text(
                        'Desbloquear',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
