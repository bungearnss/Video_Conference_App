import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

String getAgoraAppId() {
  return "YOUR APP ID";
}

checkNoSignleDigit(int no) {
  int len = no.toString().length;
  if (len == 1) {
    return true;
  }
  return false;
}

String generateRandomString(int len) {
  var r = Random();
  const chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}

Future<bool> handlePermissionsForCall(BuildContext context) async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ].request();

  if (statuses[Permission.storage]!.isPermanentlyDenied) {
    // ignore: use_build_context_synchronously
    showCustomDialog(context, "Pesmission Required",
        "Storage Permission Required for Video Call", () {
      Navigator.pop(context);
      openAppSettings();
    });
    return false;
  } else if (statuses[Permission.camera]!.isPermanentlyDenied) {
    // ignore: use_build_context_synchronously
    showCustomDialog(context, "Pesmission Required",
        "Camera Permission Required for Video Call", () {
      Navigator.pop(context);
      openAppSettings();
    });
    return false;
  } else if (statuses[Permission.microphone]!.isPermanentlyDenied) {
    // ignore: use_build_context_synchronously
    showCustomDialog(context, "Pesmission Required",
        "Microphone Permission Required for Video Call", () {
      Navigator.pop(context);
      openAppSettings();
    });
    return false;
  }

  if (statuses[Permission.storage]!.isDenied) {
    return false;
  } else if (statuses[Permission.camera]!.isDenied) {
    return false;
  } else if (statuses[Permission.microphone]!.isDenied) {
    return false;
  }
  return true;
}

void showCustomDialog(BuildContext context, String title, String message,
    Function okPressed) async {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontFamily: "WorkSansMedium"),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: "WorkSansMedium"),
          ),
          actions: [
            FlatButton(
              onPressed: () {
                okPressed;
              },
              child: const Text(
                "OK",
                style: TextStyle(fontFamily: "WorkSansMedium"),
              ),
            ),
          ],
        );
      });
}
