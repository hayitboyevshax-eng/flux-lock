import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/painting.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

/// Fon rejimidagi yuz bilan ochish: CameraPreview ko'rsatilmaydi (ramka yo'q),
/// kamera kadrlari ML Kit'ga to'g'ridan-to'g'ri uzatiladi.
///
/// DIQQAT: bu faqat "bitta yuz + ko'z qisish (liveness)" tekshiruvi.
/// Shaxsni aniqlash (embedding moslash) yo'q, shuning uchun xavfsizlik darajasi
/// past (qulaylik rejimi). PIN/pattern har doim zaxira usul.
class FaceUnlockService {
  CameraController? _cam;
  FaceDetector? _det;
  bool _busy = false;

  Future<bool> authenticate({Duration timeout = const Duration(seconds: 8)}) async {
    if (!await Permission.camera.request().isGranted) return false;
    final done = Completer<bool>();
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _cam = CameraController(front, ResolutionPreset.low,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.nv21);
      _det = FaceDetector(
        options: FaceDetectorOptions(
            enableClassification: true, performanceMode: FaceDetectorMode.fast),
      );
      await _cam!.initialize();

      var seenOpen = false, seenClosed = false;
      await _cam!.startImageStream((img) async {
        if (_busy || done.isCompleted) return;
        _busy = true;
        try {
          final input = _toInput(img, front);
          if (input == null) return;
          final faces = await _det!.processImage(input);
          if (faces.length != 1) return;
          final f = faces.first;
          if ((f.headEulerAngleY ?? 0).abs() > 25) return;
          final l = f.leftEyeOpenProbability ?? 1;
          final r = f.rightEyeOpenProbability ?? 1;
          final open = l > .7 && r > .7;
          final closed = l < .25 && r < .25;
          if (open && !seenClosed) {
            seenOpen = true;
          } else if (closed && seenOpen) {
            seenClosed = true;
          } else if (open && seenClosed) {
            if (!done.isCompleted) done.complete(true);
          }
        } catch (_) {
          // bitta kadr xatosi e'tiborsiz qoldiriladi
        } finally {
          _busy = false;
        }
      });
      return await done.future.timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    } finally {
      await dispose();
    }
  }

  InputImage? _toInput(CameraImage img, CameraDescription cam) {
    final rot = InputImageRotationValue.fromRawValue(cam.sensorOrientation);
    if (rot == null || img.planes.length != 1) return null;
    return InputImage.fromBytes(
      bytes: img.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(img.width.toDouble(), img.height.toDouble()),
        rotation: rot,
        format: InputImageFormat.nv21,
        bytesPerRow: img.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> dispose() async {
    final c = _cam, d = _det;
    _cam = null;
    _det = null;
    try {
      if (c != null && c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    await c?.dispose();
    await d?.close();
  }
}
