

import 'package:flutter/cupertino.dart';

import 'dart:convert';
import 'package:flutter/material.dart';



import 'package:flutter/widgets.dart';

class Img extends StatefulWidget {
  const Img(
      this.url, {
        this.width,
        this.height,
        this.defImagePath = "assets/images/loading.png",
      });

  final String url;
  final double? width;
  final double? height;
  final String defImagePath;

  @override
  State<StatefulWidget> createState() => _StateImageWidget();
}

class _StateImageWidget extends State<Img> {
  late Image _image;

  @override
  void initState() {
    super.initState();
    if (_isNetworkUrl(widget.url)) {
      _loadNetworkImage();
    } else {
      _loadBase64Image();
    }
  }

  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  void _loadNetworkImage() {
    _image = Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
    _setupImageErrorListener();
  }

  void _loadBase64Image() {
    String data = widget.url;

    // 处理data URI前缀
    if (data.startsWith('data:')) {
      final commaIndex = data.indexOf(',');
      if (commaIndex != -1) {
        data = data.substring(commaIndex + 1);
      }
    }

    try {
      final bytes = base64.decode(data);
      _image = Image.memory(
        bytes,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      );
      _setupImageErrorListener();
    } catch (e) {
      _setDefaultImage();
    }
  }

  void _setupImageErrorListener() {
    final ImageStream stream = _image.image.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener(
          (_, __) {},
      onError: (dynamic exception, StackTrace? stackTrace) {
        _setDefaultImage();
      },
    ));
  }

  void _setDefaultImage() {
    if (mounted) {
      setState(() {
        _image = Image.asset(
          widget.defImagePath,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _image;
  }
}
