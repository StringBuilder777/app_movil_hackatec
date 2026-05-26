import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceSignature {
  FaceSignature._();

  static List<double>? extract(Face face) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
    final noseBase = face.landmarks[FaceLandmarkType.noseBase]?.position;
    final mouthBottom = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;
    final leftEar = face.landmarks[FaceLandmarkType.leftEar]?.position;
    final rightEar = face.landmarks[FaceLandmarkType.rightEar]?.position;
    final leftCheek = face.landmarks[FaceLandmarkType.leftCheek]?.position;
    final rightCheek = face.landmarks[FaceLandmarkType.rightCheek]?.position;

    if (leftEye == null ||
        rightEye == null ||
        noseBase == null ||
        mouthBottom == null ||
        leftMouth == null ||
        rightMouth == null) {
      return null;
    }

    final dEyes = _distance(leftEye, rightEye);
    if (dEyes < 1.0) return null;

    final signature = <double>[
      _distance(noseBase, mouthBottom) / dEyes,
      _distance(leftEye, noseBase) / dEyes,
      _distance(rightEye, noseBase) / dEyes,
      _distance(leftMouth, rightMouth) / dEyes,
      face.boundingBox.height / face.boundingBox.width,
    ];

    if (leftEar != null) {
      signature.add(_distance(leftEar, leftEye) / dEyes);
    } else {
      signature.add(0.0);
    }

    if (rightEar != null) {
      signature.add(_distance(rightEar, rightEye) / dEyes);
    } else {
      signature.add(0.0);
    }

    if (leftCheek != null) {
      signature.add(_distance(noseBase, leftCheek) / dEyes);
    } else {
      signature.add(0.0);
    }

    if (rightCheek != null) {
      signature.add(_distance(noseBase, rightCheek) / dEyes);
    } else {
      signature.add(0.0);
    }

    // Contour-based features
    final leftEyeContour = face.contours[FaceContourType.leftEye];
    final rightEyeContour = face.contours[FaceContourType.rightEye];
    final noseBridge = face.contours[FaceContourType.noseBridge];
    final upperLipTop = face.contours[FaceContourType.upperLipTop];
    final lowerLipBottom = face.contours[FaceContourType.lowerLipBottom];

    signature.add(leftEyeContour != null ? _contourAspectRatio(leftEyeContour) : 0.0);
    signature.add(rightEyeContour != null ? _contourAspectRatio(rightEyeContour) : 0.0);

    if (noseBridge != null && noseBridge.points.length >= 3) {
      signature.add(_contourCurvature(noseBridge));
    } else {
      signature.add(0.0);
    }

    if (upperLipTop != null && lowerLipBottom != null) {
      final upperH = _contourHeight(upperLipTop);
      final lowerH = _contourHeight(lowerLipBottom);
      signature.add(lowerH > 0 ? upperH / lowerH : 0.0);
    } else {
      signature.add(0.0);
    }

    // Symmetry ratio: left-eye-to-nose vs right-eye-to-nose
    final leftToNose = _distance(leftEye, noseBase);
    final rightToNose = _distance(rightEye, noseBase);
    signature.add(rightToNose > 0 ? leftToNose / rightToNose : 1.0);

    // Nose-to-mouth vs eye distance ratio
    signature.add(_distance(noseBase, leftMouth) / dEyes);
    signature.add(_distance(noseBase, rightMouth) / dEyes);

    return signature;
  }

  static bool isQualitySufficient(Face face, int imageWidth, int imageHeight) {
    final yaw = face.headEulerAngleY ?? 0.0;
    final pitch = face.headEulerAngleX ?? 0.0;
    if (yaw.abs() > 18.0 || pitch.abs() > 18.0) return false;

    final faceWidth = face.boundingBox.width;
    if (faceWidth < imageWidth * 0.20) return false;

    final hasMinLandmarks = face.landmarks[FaceLandmarkType.leftEye] != null &&
        face.landmarks[FaceLandmarkType.rightEye] != null &&
        face.landmarks[FaceLandmarkType.noseBase] != null &&
        face.landmarks[FaceLandmarkType.bottomMouth] != null;
    if (!hasMinLandmarks) return false;

    return true;
  }

  static double compare(List<double> sig1, List<double> sig2) {
    if (sig1.length != sig2.length) return 0.0;

    double sumSquared = 0.0;
    int validPairs = 0;

    for (int i = 0; i < sig1.length; i++) {
      if (sig1[i] == 0.0 || sig2[i] == 0.0) continue;
      final diff = sig1[i] - sig2[i];
      sumSquared += diff * diff;
      validPairs++;
    }

    if (validPairs == 0) return 0.0;

    final euclidean = sqrt(sumSquared / validPairs);
    return exp(-3.0 * euclidean);
  }

  static List<double> average(List<List<double>> signatures) {
    if (signatures.isEmpty) return [];
    final length = signatures.first.length;
    final result = List<double>.filled(length, 0.0);

    for (final sig in signatures) {
      for (int i = 0; i < length; i++) {
        result[i] += sig[i];
      }
    }

    for (int i = 0; i < length; i++) {
      result[i] /= signatures.length;
    }

    return result;
  }

  static double _distance(Point<int> a, Point<int> b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  static double _contourAspectRatio(FaceContour contour) {
    if (contour.points.isEmpty) return 0.0;
    int minX = contour.points.first.x;
    int maxX = minX;
    int minY = contour.points.first.y;
    int maxY = minY;

    for (final p in contour.points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    final width = (maxX - minX).toDouble();
    final height = (maxY - minY).toDouble();
    return width > 0 ? height / width : 0.0;
  }

  static double _contourCurvature(FaceContour contour) {
    final points = contour.points;
    if (points.length < 3) return 0.0;

    final first = points.first;
    final mid = points[points.length ~/ 2];
    final last = points.last;

    final a = _distance(first, mid);
    final b = _distance(mid, last);
    final c = _distance(first, last);

    if (a == 0 || b == 0) return 0.0;
    final cosAngle = (a * a + b * b - c * c) / (2 * a * b);
    return cosAngle.clamp(-1.0, 1.0);
  }

  static double _contourHeight(FaceContour contour) {
    if (contour.points.isEmpty) return 0.0;
    int minY = contour.points.first.y;
    int maxY = minY;
    for (final p in contour.points) {
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    return (maxY - minY).toDouble();
  }
}
