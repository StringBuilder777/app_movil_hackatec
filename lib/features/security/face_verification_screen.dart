import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/face_recognition_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import 'face_capture_screen.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  int _attempts = 0;
  static const _maxAttempts = 3;
  bool _isVerifying = false;
  String? _resultMessage;
  bool? _isMatch;
  Key _captureKey = UniqueKey();

  Future<void> _onFaceCaptured(FaceCaptureResult result) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _resultMessage = 'Verificando identidad...';
    });

    final state = Provider.of<AppState>(context, listen: false);
    final employeeId = state.idEmpleado;
    if (employeeId == null) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final similarity = await FaceRecognitionService.instance.verify(employeeId, result.signature);

    if (!mounted) return;

    if (similarity >= 0.75) {
      setState(() {
        _isMatch = true;
        _resultMessage = 'Identidad verificada';
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, true);
    } else if (similarity >= 0.60) {
      _attempts++;
      setState(() {
        _isMatch = false;
        _isVerifying = false;
        _resultMessage = 'No se pudo confirmar. Intenta de nuevo.';
      });
      if (_attempts < _maxAttempts) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _resultMessage = null;
            _isMatch = null;
            _captureKey = UniqueKey();
          });
        }
      } else {
        _showMaxAttemptsReached();
      }
    } else {
      _attempts++;
      setState(() {
        _isMatch = false;
        _isVerifying = false;
        _resultMessage = 'Identidad no verificada';
      });
      if (_attempts >= _maxAttempts) {
        _showMaxAttemptsReached();
      } else {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _resultMessage = null;
            _isMatch = null;
            _captureKey = UniqueKey();
          });
        }
      }
    }
  }

  void _showMaxAttemptsReached() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_rounded, color: AppColors.danger, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Verificación fallida',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'No se pudo verificar tu identidad después de varios intentos. Puedes re-registrar tu rostro desde tu Perfil o contactar a tu supervisor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verificación Facial')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Verifica tu identidad',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Intento ${_attempts + 1} de $_maxAttempts',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Result banner
              if (_resultMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isMatch == true
                        ? AppColors.success.withOpacity(0.1)
                        : _isMatch == false
                            ? AppColors.danger.withOpacity(0.1)
                            : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isMatch == true
                          ? AppColors.success
                          : _isMatch == false
                              ? AppColors.danger
                              : AppColors.info,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isVerifying && _isMatch == null)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info),
                        )
                      else
                        Icon(
                          _isMatch == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: _isMatch == true ? AppColors.success : AppColors.danger,
                          size: 20,
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _resultMessage!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isMatch == true
                                ? const Color(0xFF166534)
                                : _isMatch == false
                                    ? AppColors.danger
                                    : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Camera
              Expanded(
                child: (_isVerifying || _attempts >= _maxAttempts)
                    ? Center(
                        child: _isMatch == true
                            ? const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 80)
                            : _attempts >= _maxAttempts
                                ? const Icon(Icons.block_rounded, color: AppColors.danger, size: 80)
                                : const CircularProgressIndicator(color: AppColors.primaryHighlight),
                      )
                    : FaceCaptureScreen(
                        key: _captureKey,
                        mode: FaceCaptureMode.verification,
                        title: 'Verificación',
                        subtitle: 'Mira a la cámara',
                        onFaceCaptured: _onFaceCaptured,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
