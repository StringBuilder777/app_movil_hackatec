import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/face_recognition_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import 'face_capture_screen.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  final List<List<double>> _signatures = [];
  final List<String> _photoPaths = [];
  int _captureCount = 0;
  static const _requiredCaptures = 3;
  bool _isSaving = false;
  bool _isWaiting = false;
  Key _captureKey = UniqueKey();

  void _onFaceCaptured(FaceCaptureResult result) {
    if (_isSaving) return;

    _signatures.add(result.signature);
    if (result.photoPath != null) _photoPaths.add(result.photoPath!);
    setState(() {
      _captureCount = _signatures.length;
    });

    if (_captureCount >= _requiredCaptures) {
      _saveEnrollment();
    } else {
      setState(() => _isWaiting = true);
      Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isWaiting = false;
            _captureKey = UniqueKey();
          });
        }
      });
    }
  }

  Future<void> _saveEnrollment() async {
    setState(() => _isSaving = true);

    final state = Provider.of<AppState>(context, listen: false);
    final employeeId = state.idEmpleado;
    if (employeeId == null) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final bestPhoto = _photoPaths.isNotEmpty ? _photoPaths.last : '';
    await FaceRecognitionService.instance.enroll(employeeId, _signatures, bestPhoto);

    if (mounted) {
      await showDialog(
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
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Registro exitoso',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu rostro ha sido registrado. Se usará para verificar tu identidad en cada check-in y check-out.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Registro Facial')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Vamos a registrar tu rostro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Se tomarán $_requiredCaptures capturas para mayor precisión',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_requiredCaptures, (i) {
                  final isDone = i < _captureCount;
                  final isCurrent = i == _captureCount && !_isSaving;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.primaryHighlight
                              : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded, color: AppColors.white, size: 20)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isCurrent ? AppColors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Camera or waiting state
              Expanded(
                child: _isSaving
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryHighlight),
                            SizedBox(height: 16),
                            Text('Guardando registro...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : _isWaiting
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Captura $_captureCount de $_requiredCaptures completada',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text('Preparando siguiente captura...', style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          )
                        : FaceCaptureScreen(
                            key: _captureKey,
                            mode: FaceCaptureMode.enrollment,
                            title: 'Captura ${_captureCount + 1} de $_requiredCaptures',
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
