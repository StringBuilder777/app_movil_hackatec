import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import 'permissions_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController(text: "tecnico@roceel.com");
  final _passwordController = TextEditingController(text: "password123");

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final state = Provider.of<AppState>(context, listen: false);
    final success = await state.login(_correoController.text.trim(), _passwordController.text);
    if (!mounted) return;

    if (success) {
      final bioAvailable = await BiometricAuthService.instance.isAvailable();
      if (bioAvailable && mounted) {
        final bioSuccess = await BiometricAuthService.instance.authenticate(
          reason: 'Confirma tu identidad para acceder a ROCEEL Operativo',
        );
        if (!mounted) return;
        if (!bioSuccess) {
          state.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verificación biométrica requerida para continuar.'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PermissionsScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.loginError ?? 'Error de inicio de sesión.'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // ROCEEL Logo Header
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Welcome Copy
              Text(
                'Iniciar sesión',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accede con tus credenciales de técnico',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Correo field
              CustomTextField(
                label: 'Correo electrónico',
                hint: 'Ej. usuario@roceel.com',
                controller: _correoController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password field
              CustomTextField(
                label: 'Contraseña',
                hint: 'Ingresa tu contraseña',
                controller: _passwordController,
                prefixIcon: Icons.lock_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryHighlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login Button
              CustomButton(
                text: 'Ingresar',
                icon: Icons.login_rounded,
                isLoading: state.isLoggingIn,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 80),
              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'ROCEEL Servicios Especializados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Panel Operativo v1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
