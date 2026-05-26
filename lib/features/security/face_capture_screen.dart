import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/services/face_recognition_service.dart';
import '../../core/services/face_signature.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/face_overlay_painter.dart';

enum FaceCaptureMode { enrollment, verification }

class FaceCaptureResult {
  final List<double> signature;
  final String? photoPath;
  FaceCaptureResult({required this.signature, this.photoPath});
}

class FaceCaptureScreen extends StatefulWidget {
  final FaceCaptureMode mode;
  final void Function(FaceCaptureResult result) onFaceCaptured;
  final String title;
  final String subtitle;

  const FaceCaptureScreen({
    super.key,
    required this.mode,
    required this.onFaceCaptured,
    this.title = 'Verificación facial',
    this.subtitle = 'Coloca tu rostro dentro del óvalo',
  });

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  int _frameCount = 0;
  Rect? _faceRect;
  bool _isQualityOk = false;
  String _feedbackMessage = 'Buscando rostro...';
  Size _imageSize = Size.zero;
  bool _isCaptured = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isInitialized = true);

      await _cameraController!.startImageStream(_processFrame);
    } catch (e) {
      if (mounted) {
        setState(() => _feedbackMessage = 'Error al iniciar cámara');
      }
    }
  }

  void _processFrame(CameraImage image) {
    _frameCount++;
    if (_frameCount % 3 != 0 || _isProcessing || _isCaptured) return;

    _isProcessing = true;
    _detectFace(image);
  }

  Future<void> _detectFace(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final face = await FaceRecognitionService.instance.detectFace(inputImage);

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (face == null) {
        setState(() {
          _faceRect = null;
          _isQualityOk = false;
          _feedbackMessage = 'No se detecta rostro';
        });
        _isProcessing = false;
        return;
      }

      final qualityOk = FaceSignature.isQualitySufficient(
        face,
        _imageSize.width.toInt(),
        _imageSize.height.toInt(),
      );

      String feedback;
      if (!qualityOk) {
        final yaw = face.headEulerAngleY ?? 0.0;
        final pitch = face.headEulerAngleX ?? 0.0;
        final faceWidth = face.boundingBox.width;

        if (yaw.abs() > 18.0 || pitch.abs() > 18.0) {
          feedback = 'Mira directamente a la cámara';
        } else if (faceWidth < _imageSize.width * 0.20) {
          feedback = 'Acércate más a la cámara';
        } else {
          feedback = 'Ajusta tu posición';
        }
      } else {
        feedback = 'Buena posición - capturando...';
      }

      setState(() {
        _faceRect = face.boundingBox;
        _isQualityOk = qualityOk;
        _feedbackMessage = feedback;
      });

      if (qualityOk && !_isCaptured) {
        final signature = FaceSignature.extract(face);
        if (signature != null) {
          _isCaptured = true;
          await _cameraController?.stopImageStream();

          String? photoPath;
          try {
            final xFile = await _cameraController?.takePicture();
            photoPath = xFile?.path;
          } catch (_) {}

          widget.onFaceCaptured(FaceCaptureResult(
            signature: signature,
            photoPath: photoPath,
          ));
        }
      }
    } catch (_) {
      // Ignore processing errors for individual frames
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation rotation;
    switch (sensorOrientation) {
      case 0:
        rotation = InputImageRotation.rotation0deg;
        break;
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    final format = InputImageFormat.nv21;

    _imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final bytes = image.planes.fold<List<int>>(
      [],
      (acc, plane) => acc..addAll(plane.bytes),
    );

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(bytes),
      metadata: InputImageMetadata(
        size: _imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isInitialized && _cameraController != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_cameraController!),
                      CustomPaint(
                        painter: FaceOverlayPainter(
                          detectedFaceRect: _faceRect,
                          isQualityOk: _isQualityOk,
                          imageSize: _imageSize.isEmpty ? const Size(1, 1) : _imageSize,
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryHighlight),
                ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isQualityOk
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isQualityOk ? AppColors.success : AppColors.warning,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isQualityOk ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: _isQualityOk ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _feedbackMessage,
                  style: TextStyle(
                    color: _isQualityOk ? const Color(0xFF166534) : const Color(0xFF854D0E),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
