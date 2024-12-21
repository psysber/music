import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';


import 'audio_handler.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';

class AudioManage extends GetxService {
  static final currentSongNotifier =
      ValueNotifier<MediaItem>(MediaItem(id: '', title: ''));
  static final playlistNotifier = ValueNotifier<List<MediaItem>>([]);
  static final progressNotifier = ProgressNotifier();
  static final repeatButtonNotifier = RepeatButtonNotifier();
  static final isFirstSongNotifier = ValueNotifier<bool>(true);
  static final playButtonNotifier = PlayButtonNotifier();
  static final isLastSongNotifier = ValueNotifier<bool>(false);
  static final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final _audioHandler = MyAudioHandler();
  AudioManage._internal();

  static AudioManage instance = AudioManage._internal();

  static getInstance() {
    return instance;
  }

  factory AudioManage() => getInstance();

  @override
  void onInit() async {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    _listenToCurrentPosition();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }


  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongNotifier.value = MediaItem(id: '', title: '');
      } else {
        playlistNotifier.value = playlist;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if(mediaItem!=null) {
        currentSongNotifier.value = mediaItem;
        _updateSkipButtons();
      }
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
    }
    _audioHandler.hasNext()
        ? isLastSongNotifier.value = false
        : isLastSongNotifier.value = true;
  }

  void play() => _audioHandler.play();

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  Future<void> previous() => _audioHandler.skipToPrevious();

  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void removeAtIndex(int index) {
    final length = _audioHandler.queue.value.length;

    if (index < length && length > 0) {
      _audioHandler.removeQueueItemAt(index);
    }
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  void addPlaylists(List<MediaItem> list) {
    _audioHandler.addQueueItems(list);
  }

  void clearPlayLists() {
    stop();
    _audioHandler.clear();
  }

  int getLength() {
    return _audioHandler.getLength();
  }

  void playOrPauseById(int mediaId) {
    _audioHandler.playOrPauseById(mediaId);
  }

  void skipToNext() {
    _audioHandler.skipToNext();
  }
}
