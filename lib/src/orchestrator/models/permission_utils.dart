import "package:camera_awesome/pigeon.dart";

extension PermissionsUtils on CamerAwesomePermission {
  static List<CamerAwesomePermission> get needed => <CamerAwesomePermission>[
        CamerAwesomePermission.camera,
        //CamerAwesomePermission.storage,
      ];
}

extension PermissionsMatcher on List<CamerAwesomePermission> {
  bool hasRequiredPermissions() {
    for (final CamerAwesomePermission p in PermissionsUtils.needed) {
      if (!contains(p)) {
        return false;
      }
    }
    return true;
  }
}
