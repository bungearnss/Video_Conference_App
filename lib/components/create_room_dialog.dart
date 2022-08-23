import 'package:flutter/material.dart';
import 'package:flutter_videocall_app/screen/videocall_room_screen.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../helper/text_styles.dart';
import '../helper/utils.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({Key? key}) : super(key: key);

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  String roomId = "";

  @override
  void initState() {
    super.initState();
    roomId = generateRandomString(8);
  }

  _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      "Hey There, Lets Connect via Video call in App using code: $roomId",
      subject: "Video Call Invite",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.close,
              color: Colors.grey[400],
            ),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 5),
          const Text("Room Created"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/open-door.png",
            fit: BoxFit.contain,
          ),
          RichText(
            text: TextSpan(
              text: "Room id : ",
              style: midTxtStyle.copyWith(
                color: const Color(0xFF1A1E78),
              ),
              children: [
                TextSpan(
                  text: roomId,
                  style: midTxtStyle.copyWith(
                    color: const Color(0xFF1A1E78),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: const Color(0xFF1A1E78),
                onPressed: () {
                  /* shareToApps(roomId); */
                  _onShare(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "Share",
                      style: regularTxtStyle,
                    )
                  ],
                ),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: const Color(0xFF1A1E78),
                onPressed: () async {
                  bool isPermissionGranted =
                      await handlePermissionsForCall(context);
                  if (isPermissionGranted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoCallScreen(channelName: roomId),
                      ),
                    );
                  } else {
                    Get.snackbar(
                      "Failed",
                      "Microphone Permission Required for Video Call.",
                      backgroundColor: Colors.white,
                      colorText: const Color(0xFF1A1E78),
                      snackPosition: SnackPosition.BOTTOM,
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
                    Text(
                      "Join",
                      style: regularTxtStyle,
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
