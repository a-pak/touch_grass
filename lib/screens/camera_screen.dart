// TODO: Kun kuva on otettu, niin pitäisi olla kaksi nappia
// Ylempänä "send to API" ja alempana "take another photo".
// refaktoroi rivit 219-239 renderöimään _capturedImageBytes tilan perusteella

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();

  CameraController? _cameraController;
  Uint8List? _capturedImageBytes;
  bool _isInitializingCamera = true;
  bool _isTakingPicture = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.disposeController(_cameraController);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializingCamera = true;
      _errorMessage = null;
    });

    try {
      final CameraController controller = await _cameraService.initializeCamera();

      if (!mounted) {
        await _cameraService.disposeController(controller);
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializingCamera = false;
      });
    } on CameraException catch (error) {
      setState(() {
        _isInitializingCamera = false;
        _errorMessage = _cameraExceptionMessage(error);
      });
    } on CameraServiceException catch (error) {
      setState(() {
        _isInitializingCamera = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        _isInitializingCamera = false;
        _errorMessage = 'Could not start the camera. Please try again.';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final CameraController? controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
      _errorMessage = null;
    });

    try {
      final XFile imageFile = await _cameraService.takePicture(controller);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _capturedImageBytes = imageBytes;
        _isTakingPicture = false;
      });

      // Placeholder: call future plant-recognition flow with this image.
      // Example hook:
      // await PlantRecognitionService().identifyPlant(imageBytes);
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTakingPicture = false;
        _errorMessage = _cameraExceptionMessage(error);
      });
    } on CameraServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTakingPicture = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTakingPicture = false;
        _errorMessage = 'Failed to capture photo. Please try again.';
      });
    }
  }

  Future<void> _retakePhoto() async {
    final CameraController? controller = _cameraController;

    setState(() {
      _capturedImageBytes = null;
      _errorMessage = null;
    });

    if (controller == null) {
      await _initializeCamera();
      return;
    }

    try {
      await _cameraService.resumePreviewIfNeeded(controller);
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _cameraExceptionMessage(error);
      });
      await _initializeCamera();
    } on CameraServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
      await _initializeCamera();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Could not reopen camera preview. Trying again...';
      });
      await _initializeCamera();
    }
  }

  String _cameraExceptionMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Camera permission denied. Please allow camera access in settings.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Camera permission denied permanently. Enable it in system settings.';
      case 'CameraAccessRestricted':
        return 'Camera access is restricted on this device.';
      case 'AudioAccessDenied':
        return 'Audio permission denied. The camera can still work without audio.';
      default:
        return error.description ?? 'Camera error: ${error.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Camera',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildCameraArea()),
            const SizedBox(height: 12),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _canCapture ? _capturePhoto : null,
                icon: _isTakingPicture
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(_isTakingPicture ? 'Capturing...' : 'Take Photo'),
              ),
            ),
            if (_capturedImageBytes != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _retakePhoto,
                child: const Text('Take Another Photo'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _canCapture {
    return !_isInitializingCamera &&
        !_isTakingPicture &&
        _cameraController != null &&
        _cameraController!.value.isInitialized;
  }

  Widget _buildCameraArea() {
    if (_isInitializingCamera) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_capturedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _capturedImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Camera is unavailable.'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}
