import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:get/get.dart';

class OperationController extends GetxController {
  bool muteAudio = false;
  bool muteVideo = false;
  late RtcEngine _engine;

  void onToggleMuteAudio() {
    muteAudio = !muteAudio;

    _engine.muteLocalAudioStream(muteAudio);
  }

  void onToggleMuteVideo() {
    muteVideo = !muteVideo;
    _engine.muteLocalVideoStream(muteVideo);
  }
}
