import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/text_styles.dart';
import '../helper/utils.dart';
import '../screen/videocall_room_screen.dart';

class JoinRoomDialog extends StatelessWidget {
  final TextEditingController roomTxtController = TextEditingController();

  JoinRoomDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Join Room"),
      content: SizedBox(
        width: 250,
        height: height * 0.44,
        child: ListView(
          shrinkWrap: true,
          children: [
            Image.asset("assets/join_room.png", height: 150, width: 120),
            const SizedBox(height: 10),
            TextFormField(
              controller: roomTxtController,
              decoration: const InputDecoration(
                hintText: "Enter room id to join",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A1E78), width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A1E78), width: 2),
                ),
              ),
              style: regularTxtStyle.copyWith(
                color: const Color(0xFF1A1E78),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: const Color(0xFF1A1E78),
              onPressed: () async {
                if (roomTxtController.text.isNotEmpty) {
                  bool isPermissionGranted =
                      await handlePermissionsForCall(context);
                  if (isPermissionGranted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          channelName: roomTxtController.text,
                        ),
                      ),
                    );
                  } else {
                    Get.snackbar(
                      "Failed",
                      "Enter Room-Id to Join.",
                      backgroundColor: Colors.white,
                      colorText: const Color(0xFF1A1E78),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.only(bottom: 5),
                    );
                  }
                } else {
                  Get.snackbar(
                    "Failed",
                    "Microphone Permission Required for Video Call.",
                    backgroundColor: Colors.white,
                    colorText: const Color(0xFF1A1E78),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.only(bottom: 5),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 20),
                  Text("Join Room", style: regularTxtStyle),
                ],
              ),
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: const Color.fromARGB(255, 193, 18, 12),
              onPressed: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Cancel", style: regularTxtStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
