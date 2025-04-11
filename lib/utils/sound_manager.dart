import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _musicPlayer = AudioPlayer();
  static final AudioPlayer _soundPlayer = AudioPlayer();

  static Future<void> toggleMusic(bool play) async {
    try {
      if (play) {
        await _musicPlayer.setSource(AssetSource('music/background.mp3'));
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer.resume();
      } else {
        await _musicPlayer.stop();
      }
    } catch (e) {
      // In a production app, use a logging framework instead
    }
  }

  static Future<void> playSound(String sound) async {
    try {
      await _soundPlayer.play(AssetSource('sounds/$sound.mp3'));
    } catch (e) {
      // In a production app, use a logging framework instead
    }
  }
}