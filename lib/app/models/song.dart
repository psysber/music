class Song {
  final String title;
  final String? artist;
  final String ? albumTitle;
  final String?  genre;
  final double ? playbackDuration;
  final int ? albumTrackNumber;
  final int ? albumTrackCount;
  final int ? discNumber;
  final int ? discCount;
  final bool ? isExplicitItem;
  final DateTime?  releaseDate;
  final int ? playCount;
  final int ? skipCount;
  final int ? rating;
  final DateTime ? lastPlayedDate;
  final String ? albumArtwork; // 新增字段
  final double ? sampleRate; // 新增字段
  final double ? bitRate;

  final url; // 新增字段

  Song({
     this.url,
     required this.title,
     this.artist,
     this.albumTitle,
     this.genre,
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
     this.albumArtwork, // 新增字段
     this.sampleRate, // 新增字段
     this.bitRate, // 新增字段
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      artist: json['artist'],
      albumTitle: json['albumTitle'],
      genre: json['genre'],
      playbackDuration: json['playbackDuration'],
      albumTrackNumber: json['albumTrackNumber'],
      albumTrackCount: json['albumTrackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      isExplicitItem: json['isExplicitItem'],
      releaseDate: DateTime.parse(json['releaseDate']),
      playCount: json['playCount'],
      skipCount: json['skipCount'],
      rating: json['rating'],
      lastPlayedDate: DateTime.parse(json['lastPlayedDate']),
      albumArtwork: json['albumArtwork'],
      sampleRate: json['sampleRate'], 
      bitRate: json['bitRate'],
      url: json['url']
    );
  }


}