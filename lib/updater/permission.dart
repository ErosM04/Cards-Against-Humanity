import 'package:permission_handler/permission_handler.dart';

class PermissionChecker {
  const PermissionChecker();

  // CHECKS

  /// Return true if the given Permission is granted (doesn't ask for it).
  static Future<bool> checkPermission(Permission permission) async =>
      permission.isGranted;

  static Future<bool> checkInstallPackages() async =>
      checkPermission(Permission.requestInstallPackages);

  static Future<bool> checkExternalStorage() async =>
      checkPermission(Permission.manageExternalStorage);

  // -----------------------------------------------
  // REQUESTS

  static void requestPermission(
      Permission permission, Function onGranted, Function onDenied) async {
    if (await checkPermission(permission)) {
      // Permission has already been granted
      onGranted();
    } else {
      // Asks for permission
      if (await permission.request().isGranted) {
        // Permission is granted
        onGranted();
      } else {
        // Permission is denied
        onDenied();
      }
    }
  }

  static void requestInstallPackages(
          {required Function onGranted, required Function onDenied}) async =>
      requestPermission(Permission.requestInstallPackages, onGranted, onDenied);

  static void requestExternalStorage(
          {required Function onGranted, required Function onDenied}) async =>
      requestPermission(Permission.manageExternalStorage, onGranted, onDenied);
}
