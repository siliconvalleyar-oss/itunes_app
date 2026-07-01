import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAudioPermission() async {
    if (!Platform.isAndroid) return true;

    var status = await Permission.audio.request();
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  static Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid) return true;

    if (await Permission.audio.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    return false;
  }
}
