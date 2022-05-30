// import 'package:permission_handler/permission_handler.dart';

// class PhonePermission {
//   PhonePermission._();

//   static Future<bool> check() async {
//     if (await Permission.photos.status != PermissionStatus.granted) {
//       final ret = await Permission.photos.request();
//       print('ret:${ret.toString()}');
//       openAppSettings();
//       return Future.value(ret == PermissionStatus.granted);
//     }
//     return Future.value(true);
//   }
// }
