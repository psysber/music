import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScrollText extends StatefulWidget {
  final String child;
  final TextStyle? style;
  ScrollText({Key? key, required this.child, this.style}) : super(key: key);

  @override
  _ScrollTextState createState() => _ScrollTextState();
}

class _ScrollTextState extends State<ScrollText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 20));
    _animation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(-1.0, 0.0))
        .animate(_controller);

    _animation.addListener(() {
      setState(() {});
    });
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: FractionalTranslation(
            translation: _animation.value,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: InkWell(
                  onTap: () {
                    if (_controller.isAnimating) {
                      _controller.stop();
                    } else {
                      _controller.repeat();
                    }
                  },
                  child: Text(
                    widget.child,
                    key: _globalKey,
                    style: widget.style,
                  ),
                ))));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
