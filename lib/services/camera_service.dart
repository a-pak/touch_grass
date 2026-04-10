import 'package:camera/camera.dart';

class CameraService {
  Future<CameraController> initializeCamera() async {
    final List<CameraDescription> cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw const CameraServiceException('No camera is available on this device.');
    }

    final CameraDescription selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final CameraController controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller.initialize();
    return controller;
  }

  Future<XFile> takePicture(CameraController controller) async {
    if (!controller.value.isInitialized) {
      throw const CameraServiceException('Camera is not initialized.');
    }

    if (controller.value.isTakingPicture) {
      throw const CameraServiceException('A photo is already being captured.');
    }

    return controller.takePicture();
  }

  Future<void> resumePreviewIfNeeded(CameraController controller) async {
    if (!controller.value.isInitialized) {
      throw const CameraServiceException('Camera is not initialized.');
    }

    if (controller.value.isPreviewPaused) {
      await controller.resumePreview();
    }
  }

  Future<void> disposeController(CameraController? controller) async {
    await controller?.dispose();
  }
}

class CameraServiceException implements Exception {
  const CameraServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
