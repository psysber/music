//封装图片加载控件，增加图片加载失败时加载默认图片
import 'package:flutter/cupertino.dart';

class Img extends StatefulWidget {
  Img(this.url,{      this.width, this.height, this.defImagePath = "assets/images/loading.png"});

  final String url;
  final double? width;
  final double? height;
  final String defImagePath;

  @override
  State<StatefulWidget> createState() {
    return _StateImageWidget();
  }
}

class _StateImageWidget extends State<Img> {
  late Image _image;

  @override
  void initState() {
    super.initState();
    _image = Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
    var resolve = _image.image.resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((_, __) {
      //加载成功
    },onError: (_,__){
      setState(() {
        _image = Image.asset(
          widget.defImagePath,
          width: widget.width,
          height: widget.height,
        );
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return _image;
  }
}