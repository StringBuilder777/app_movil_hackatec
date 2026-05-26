import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'face_signature.dart';

class FaceRecognitionService {
  FaceRecognitionService._();
  static final instance = FaceRecognitionService._();

  final _storage = const FlutterSecureStorage();

  FaceDetector? _detector;

  FaceDetector get detector {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.25,
      ),
    );
    return _detector!;
  }

  String _storageKey(int employeeId) => 'face_enrollment_$employeeId';

  Future<String> _photoDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/face_enrollment');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  String _photoFileName(int employeeId) => 'face_ref_$employeeId.jpg';

  Future<bool> isEnrolled(int employeeId) async {
    final data = await _storage.read(key: _storageKey(employeeId));
    if (data == null) return false;
    final photoPath = await getEnrollmentPhotoPath(employeeId);
    return photoPath != null;
  }

  Future<Face?> detectFace(InputImage image) async {
    final faces = await detector.processImage(image);
    if (faces.isEmpty) return null;

    Face largest = faces.first;
    double largestArea = largest.boundingBox.width * largest.boundingBox.height;

    for (final face in faces.skip(1)) {
      final area = face.boundingBox.width * face.boundingBox.height;
      if (area > largestArea) {
        largest = face;
        largestArea = area;
      }
    }

    return largest;
  }

  Future<void> enroll(
    int employeeId,
    List<List<double>> signatures,
    String referencePhotoPath,
  ) async {
    // Copy the reference photo to permanent storage
    final dir = await _photoDir();
    final destPath = '$dir/${_photoFileName(employeeId)}';
    final sourceFile = File(referencePhotoPath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destPath);
    }

    final avgSignature = FaceSignature.average(signatures);
    final data = {
      'employee_id': employeeId,
      'signatures': signatures.map((s) => s.toList()).toList(),
      'average_signature': avgSignature,
      'photo_path': destPath,
      'enrolled_at': DateTime.now().toIso8601String(),
      'version': 2,
    };
    await _storage.write(
      key: _storageKey(employeeId),
      value: jsonEncode(data),
    );
  }

  Future<Map<String, dynamic>?> getEnrollment(int employeeId) async {
    final raw = await _storage.read(key: _storageKey(employeeId));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      await clearEnrollment(employeeId);
      return null;
    }
  }

  Future<String?> getEnrollmentPhotoPath(int employeeId) async {
    final enrollment = await getEnrollment(employeeId);
    if (enrollment == null) return null;
    final path = enrollment['photo_path'] as String?;
    if (path != null && await File(path).exists()) return path;
    return null;
  }

  Future<double> verify(int employeeId, List<double> capturedSignature) async {
    final enrollment = await getEnrollment(employeeId);
    if (enrollment == null) return 0.0;

    final storedSig = (enrollment['average_signature'] as List)
        .map<double>((e) => (e as num).toDouble())
        .toList();

    return FaceSignature.compare(storedSig, capturedSignature);
  }

  Future<void> clearEnrollment(int employeeId) async {
    try {
      final dir = await _photoDir();
      final photoFile = File('$dir/${_photoFileName(employeeId)}');
      if (await photoFile.exists()) await photoFile.delete();
    } catch (_) {}
    await _storage.delete(key: _storageKey(employeeId));
  }

  void dispose() {
    _detector?.close();
    _detector = null;
  }
}
