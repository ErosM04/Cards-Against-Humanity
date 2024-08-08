import 'package:permission_handler/permission_handler.dart';

/// Simplifies the action of controlling and requesting for permissions.
class PermissionChecker {
  const PermissionChecker();

  // CHECKS

  /// Return true if the given Permission is granted (doesn't ask for it).
  static Future<bool> checkPermission(Permission permission) async =>
      permission.isGranted;

  /// Return true if the permission of **installing a package** is granted (doesn't ask for it).
  static Future<bool> checkInstallPackages() async =>
      checkPermission(Permission.requestInstallPackages);

  /// Return true if the permission of **accessing the external storage** is granted (doesn't ask for it).
  static Future<bool> checkExternalStorage() async =>
      checkPermission(Permission.manageExternalStorage);

  // REQUESTS

  /// Chechks if ``[permission]`` has already been granted, otherwise asks for it.
  ///
  /// #### Parameters
  /// - ``Permission permission`` : the type of permission to ask for;
  /// - ``Function onGranted`` : the function to execute if the permission has already been granted or is granted after
  /// the request;
  /// - ``Function onDenied`` :  the function to execute if the permission is not granted.
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

  /// Chechks if the permission of **installing a package** has already been granted, otherwise asks for it.
  ///
  /// #### Parameters
  /// - ``Function onGranted`` : the function to execute if the permission has already been granted or is granted after
  /// the request;
  /// - ``Function onDenied`` :  the function to execute if the permission is not granted.
  static void requestInstallPackages(
          {required Function onGranted, required Function onDenied}) async =>
      requestPermission(Permission.requestInstallPackages, onGranted, onDenied);

  /// Chechks if the permission of **accessing the external storage** has already been granted, otherwise asks for it.
  ///
  /// #### Parameters
  /// - ``Function onGranted`` : the function to execute if the permission has already been granted or is granted after
  /// the request;
  /// - ``Function onDenied`` :  the function to execute if the permission is not granted.
  static void requestExternalStorage(
          {required Function onGranted, required Function onDenied}) async =>
      requestPermission(Permission.manageExternalStorage, onGranted, onDenied);
}
