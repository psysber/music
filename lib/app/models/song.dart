class Song {
  final String title;
  final String artist;
  final String albumTitle;
  final String genre;
  final double? playbackDuration;
  final int? albumTrackNumber;
  final int? albumTrackCount;
  final int? discNumber;
  final int? discCount;
  final bool? isExplicitItem;
  final DateTime? releaseDate;
  final int? playCount;
  final int? skipCount;
  final int? rating;
  final DateTime? lastPlayedDate;
  final String albumArtwork;
  final double? sampleRate;
  final double? bitRate;
  final String url;

  Song({
    this.title = 'Unknown Title',
    this.artist = 'Unknown Artist',
    this.albumTitle = 'Unknown Album',
    this.genre = 'Unknown Genre',
    this.playbackDuration,
    this.albumTrackNumber,
    this.albumTrackCount,
    this.discNumber,
    this.discCount,
    this.isExplicitItem,
    this.releaseDate,
    this.playCount,
    this.skipCount,
    this.rating,
    this.lastPlayedDate,
    this.albumArtwork = '',
    this.sampleRate,
    this.bitRate,
    this.url = '',
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      albumTitle: json['albumTitle'] as String? ?? 'Unknown Album',
      genre: json['genre'] as String? ?? 'Unknown Genre',
      playbackDuration: json['playbackDuration'] as double?,
      albumTrackNumber: json['albumTrackNumber'] as int?,
      albumTrackCount: json['albumTrackCount'] as int?,
      discNumber: json['discNumber'] as int?,
      discCount: json['discCount'] as int?,
      isExplicitItem: json['isExplicitItem'] as bool?,
      releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate'] as String) : null,
      playCount: json['playCount'] as int?,
      skipCount: json['skipCount'] as int?,
      rating: json['rating'] as int?,
      lastPlayedDate: json['lastPlayedDate'] != null ? DateTime.parse(json['lastPlayedDate'] as String) : null,
      albumArtwork: json['albumArtwork'] as String? ?? '',
      sampleRate: json['sampleRate'] as double?,
      bitRate: json['bitRate'] as double?,
      url: json['url'] as String? ?? '',
    );
  }

  static List<Song> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => Song.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'Song{'
        'title: $title, '
        'artist: $artist, '
        'albumTitle: $albumTitle, '
        'genre: $genre, '
        'playbackDuration: $playbackDuration, '
        'albumTrackNumber: $albumTrackNumber, '
        'albumTrackCount: $albumTrackCount, '
        'discNumber: $discNumber, '
        'discCount: $discCount, '
        'isExplicitItem: $isExplicitItem, '
        'releaseDate: $releaseDate, '
        'playCount: $playCount, '
        'skipCount: $skipCount, '
        'rating: $rating, '
        'lastPlayedDate: $lastPlayedDate, '
        'albumArtwork: $albumArtwork, '
        'sampleRate: $sampleRate, '
        'bitRate: $bitRate, '
        'url: $url'
        '}';
  }
}