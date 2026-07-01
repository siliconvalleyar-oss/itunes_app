import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static bool get _isAndroid13Plus {
    if (!Platform.isAndroid) return false;
    final version = Platform.version;
    final sdk = int.tryParse(version.split(' ').first);
    return sdk != null && sdk >= 33;
  }

  static Future<bool> requestAudioPermission() async {
    if (!Platform.isAndroid) return true;

    final permission = _isAndroid13Plus ? Permission.audio : Permission.storage;
    final status = await permission.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  static Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid) return true;

    final permission = _isAndroid13Plus ? Permission.audio : Permission.storage;
    return await permission.isGranted;
  }
}
