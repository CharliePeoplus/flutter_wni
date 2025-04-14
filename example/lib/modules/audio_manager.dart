import 'package:audioplayers/audioplayers.dart';

class AudioManager {

  // Singleton
  static final _instance = AudioManager._internal();
  static get instance => _instance;
  factory AudioManager() { return _instance; }
  // ignore: empty_constructor_bodies
  AudioManager._internal() {
    _player = AudioCache();
  }
  
  // Private
  late AudioCache _player;

  // Lifecycles
  void play(String audioId) {
    _player.play("assets/$audioId.wav");
  }
}