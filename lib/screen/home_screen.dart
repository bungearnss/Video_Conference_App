import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/create_room_dialog.dart';
import '../components/join_room_dialog.dart';
import '../helper/text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1E78),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60, left: 30),
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Meeting App",
                  style: largeTxtStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Easy connect with friends via video call.",
                  style: largeTxtStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.only(top: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Center(
                  child: Column(
                children: [
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FlatButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return const CreateRoomDialog();
                              });
                        },
                        child: Row(children: [
                          Flexible(
                            flex: 7,
                            child: Image.asset(
                              "assets/create.png",
                              fit: BoxFit.fill,
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Create Room",
                                  style: largeTxtStyle.copyWith(
                                      color: const Color(0xFF1A1E78)),
                                ),
                                Text(
                                  "create a unique agora room and ask others to join the same.",
                                  style: regularTxtStyle.copyWith(
                                      color: const Color(0xFF1A1E78)),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 2,
                      margin: const EdgeInsets.all(20),
                      color: const Color(0xFF1A1E78),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FlatButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return JoinRoomDialog();
                              });
                        },
                        child: Row(
                          children: [
                            Flexible(
                              flex: 6,
                              child: Image.asset(
                                "assets/join.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Join Room",
                                    style: largeTxtStyle.copyWith(
                                        color: const Color(0xFF1A1E78)),
                                  ),
                                  Text(
                                    "Join a agora room created by your friend.",
                                    style: largeTxtStyle.copyWith(
                                        color: const Color(0xFF1A1E78)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1E78),
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              useSafeArea: false,
              builder: (_) {
                return const CreateRoomDialog();
              });
        },
      ),
    );
  }
}
