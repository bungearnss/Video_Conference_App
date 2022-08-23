// ignore_for_file: unnecessary_string_escapes

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import '../controller/operation_controller.dart';
import './home_screen.dart';
import '../helper/utils.dart';

class VideoCallScreen extends StatefulWidget {
  String channelName;

  VideoCallScreen({required this.channelName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  static final _user = <int>[];
  final _infoString = <String>[];
  late RtcEngine _engine;

  bool backCamera = false;
  late double screenWidth;
  late double screenHeight;
  // UserJoined logic
  bool isUserJoinCall = false;
  final OperationController operationController =
      Get.put(OperationController());

  //Meeting Timer Helper
  Timer? meetingTimer;
  int timerStart = 0;
  String timerTxt = "00:00";
  int networkQuality = 3;
  Color networkQualityBarColor = Colors.green;

  void startMeetingTimer() async {
    const oneSec = Duration(seconds: 1);

    meetingTimer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          int min = timerStart ~/ 60;
          int sec = (timerStart % 60).toInt();

          timerTxt = "$min:$sec";

          if (checkNoSignleDigit(min)) {
            timerTxt = "0$min:$sec";
          }
          if (checkNoSignleDigit(sec)) {
            if (checkNoSignleDigit(min)) {
              timerTxt = "0$min:0$sec";
            } else {
              timerTxt = "$min:0$sec";
            }
          }

          timerStart = timerStart + 1;
        },
      ),
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(getAgoraAppId());
    await _engine.enableVideo();
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          print("======== AGORA ERROR  : ======= $code");
          setState(() {
            final info = "onError: $code";
            _infoString.add(info);
          });
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          print("======================================");
          print("        ON JOIN CHANNEL SUCESS        ");
          print("======================================");
          setState(() {
            final info = "onJoinChannel: $channel, uid: $uid";
            _infoString.add(info);
          });
        },
        userOffline: (uid, reason) {
          print("======== AGORA User OFFLINE : ======= $reason");
          setState(() {
            final info = "userOffline: $uid";
            _infoString.add(info);
            _user.remove(uid);
          });
        },
        userJoined: (uid, elapsed) {
          print("======================================");
          print("             User Joined              ");
          print("======================================");

          if (meetingTimer != null) {
            if (meetingTimer!.isActive) {
              startMeetingTimer();
            }
          } else {
            startMeetingTimer();
          }

          isUserJoinCall = true;
          setState(() async {
            final info = "UserJoined: $uid";
            _infoString.add(info);
            _user.add(uid);
          });
        },
        leaveChannel: (stats) {
          setState(() {
            _infoString.add("UserLeaveChannel");
            _user.clear();
          });
        },
        networkTypeChanged: (type) {
          print("=========NETWORK TYPE=======");
          print("=======     $type   =====");
          print("============================");
        },
        networkQuality: (uid, txQa, rxQa) {
          setState(() {
            networkQuality = getNetworkQuality(txQa);
            networkQualityBarColor = getNetworkQualityBarColor(networkQuality);
          });
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          setState(() {
            final info = 'firstRemoteVideoFrame: $uid';
            _infoString.add(info);
          });
        },
        userMuteAudio: (uid, muted) {
          print("USER MIC MUTE $muted");
        },
      ),
    );
  }

  Future<void> initAgoraRTC() async {
    if (getAgoraAppId().isEmpty) {
      Get.snackbar("", "Agora APP_ID Is Not Valid");
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":640,\"height\":360,\"frameRate\":30,\"bitRate\":800}}''');
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  @override
  void initState() {
    super.initState();
    initAgoraRTC();
  }

  void onPaused() async {
    meetingTimer!.cancel();
    await _engine.disableAudio();
    await _engine.disableVideo();
  }

  void onResumed() async {
    startMeetingTimer();
    await _engine.enableAudio();
    await _engine.enableVideo();
  }

  @override
  void dispose() {
    super.dispose();
    print("\n============ ON DISPOSE CALLED ===============\n");

    if (meetingTimer != null) {
      meetingTimer!.cancel();
    }

    // clear user
    _user.clear();
    _engine.leaveChannel();
    _engine.destroy();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    bool shouldPop = true;

    return WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Scaffold(
        body: buildNormalVideoUI(),
        bottomNavigationBar: GetBuilder<OperationController>(builder: (_) {
          return ConvexAppBar(
            style: TabStyle.fixedCircle,
            backgroundColor: const Color(0xFF1A1E78),
            color: Colors.white,
            items: [
              TabItem(
                icon: _.muteAudio ? Icons.mic_off_outlined : Icons.mic_outlined,
              ),
              const TabItem(
                icon: Icons.call_end_rounded,
              ),
              TabItem(
                icon: _.muteVideo
                    ? Icons.videocam_off_outlined
                    : Icons.videocam_outlined,
              ),
            ],
            initialActiveIndex: 2,
            onTap: (i) {
              print("iiiiiii $i");
              switch (i) {
                case 0:
                  _.onToggleMuteAudio();
                  break;
                case 1:
                  onCallEnd(context);
                  break;
                case 2:
                  _.onToggleMuteVideo();
                  break;
              }
            },
          );
        }),
      ),
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(const RtcLocalView.SurfaceView());
    for (var uid in _user) {
      list.add(RtcRemoteView.SurfaceView(
        uid: uid,
        channelId: widget.channelName,
      ));
    }
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(child: Row(children: wappedViews));
  }

  Widget buildJoinUserUI() {
    final views = _getRenderViews();
    print("=================================");
    print("           Length ${views.length}");
    print("=================================");

    switch (views.length) {
      case 1:
        return Column(
          children: <Widget>[_videoView(views[0])],
        );
      case 2:
        return Container(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      _expandedVideoRow([views[1]]),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 8,
                        color: Colors.white38,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.fromLTRB(15, 40, 10, 15),
                    width: 110,
                    height: 140,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _expandedVideoRow([views[0]]),
                      ],
                    ),
                  ),
                ),
              ],
            ));
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        );
      default:
    }
    return Container();
  }

  void onCallEnd(BuildContext context) async {
    if (meetingTimer != null) {
      if (meetingTimer!.isActive) {
        meetingTimer!.cancel();
      }
    }
    if (isUserJoinCall) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          title: const Text("Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                  "No one has not joined this call yet,\nDo You want to close this room?")
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: const Text("Yes"),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
          ],
        ),
      );
    }
  }

  void _onSwitchCamera() {
    setState(() {
      backCamera = !backCamera;
    });
    _engine.switchCamera();
  }

  Widget buildNormalVideoUI() {
    return SizedBox(
      height: screenHeight,
      child: Stack(children: [
        buildJoinUserUI(),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 10, top: 30),
            child: FlatButton(
              minWidth: 40,
              height: 50,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: Colors.white38,
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 0, left: 10, bottom: 10),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SignalStrengthIndicator.bars(
                  value: networkQuality,
                  size: 18,
                  barCount: 4,
                  spacing: 0.3,
                  maxValue: 4,
                  activeColor: networkQualityBarColor,
                  inactiveColor: Colors.white,
                  radius: const Radius.circular(8),
                  minValue: 0,
                ),
                const SizedBox(width: 8),
                Text(
                  timerTxt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0.0, 2.0),
                        blurRadius: 2.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.only(right: 10, bottom: 4),
            child: RawMaterialButton(
              onPressed: _onSwitchCamera,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              fillColor: Colors.white38,
              child: Icon(
                backCamera ? Icons.camera_rear : Icons.camera_front_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void addLogToList(String info) {
    print(info);
    setState(() {
      _infoString.insert(0, info);
    });
  }

  int getNetworkQuality(NetworkQuality txQa) {
    switch (txQa) {
      case NetworkQuality.Good:
        return 2;
      case NetworkQuality.Excellent:
        return 4;
      case NetworkQuality.Poor:
        return 3;
      case NetworkQuality.Bad:
        return 2;
      case NetworkQuality.VBad:
        return 1;
      default:
    }
    return 0;
  }

  Color getNetworkQualityBarColor(int txQa) {
    switch (txQa) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.redAccent;
      case 4:
        return Colors.red;
    }
    return Colors.yellow;
  }
}
