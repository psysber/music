import 'dart:ffi';

import 'package:get/get_common/get_reset.dart';
class Song {
  final String title;
  final String artist;
  final String albumTitle;
  final String genre;
  final dynamic? playbackDuration;
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
  final String? id;
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
    this.albumArtwork ='',
    this.sampleRate,
    this.bitRate,
    this.url = '',
    this.id = ''
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'albumTitle': albumTitle,
      'genre': genre,
      'playbackDuration': playbackDuration,
      'albumTrackNumber': albumTrackNumber,
      'albumTrackCount': albumTrackCount,
      'discNumber': discNumber,
      'discCount': discCount,
      'isExplicitItem': isExplicitItem,
      'releaseDate': releaseDate?.toIso8601String(),
      'playCount': playCount,
      'skipCount': skipCount,
      'rating': rating,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'albumArtwork': albumArtwork,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
      'url': url,
      'id': id,
    };}

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      albumTitle: json['albumTitle'] as String? ?? 'Unknown Album',
      genre: json['genre'] as String? ?? 'Unknown Genre',
      playbackDuration: _parseDynamic(json['playbackDuration']),
      albumTrackNumber: _parseInt(json['albumTrackNumber']),
      albumTrackCount: _parseInt(json['albumTrackCount']),
      discNumber: _parseInt(json['discNumber']),
      discCount: _parseInt(json['discCount']),
      isExplicitItem: _parseBool(json['isExplicitItem']),
      releaseDate: _parseDateTime(json['releaseDate']),
      playCount: _parseInt(json['playCount']),
      skipCount: _parseInt(json['skipCount']),
      rating: _parseInt(json['rating']),
      lastPlayedDate: _parseDateTime(json['lastPlayedDate']),
      albumArtwork: json['albumArtwork'] as String? ?? '',
      sampleRate: _parseDouble(json['sampleRate']),
      bitRate: _parseDouble(json['bitRate']),
      url: json['url'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }

// 辅助方法：将动态类型转换为 int
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

// 辅助方法：将动态类型转换为 double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

// 辅助方法：将动态类型转换为 bool
  static bool _parseBool(dynamic value) {
    if (value == null) return false; // 默认值
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true'; // 支持 "true" 或 "false"
    }
    return false; // 其他类型默认返回 false
  }

// 辅助方法：将动态类型转换为 DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value); // 尝试解析字符串为 DateTime
      } catch (e) {
        return null; // 解析失败返回 null
      }
    }
    return null; // 其他类型返回 null
  }

// 辅助方法：处理 playbackDuration 的动态类型
  static dynamic _parseDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int || value is double || value is String) return value;
    return null;
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
        'bitRate: $bitRate,'
        'id: $id,'
        'url: $url'
        '}';
  }
}

