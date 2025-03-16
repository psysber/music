import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmoothTextSwitcher extends StatefulWidget {
  final List<String> texts;

  const SmoothTextSwitcher({super.key, required this.texts});

  @override
  State<SmoothTextSwitcher> createState() => _SmoothTextSwitcherState();
}

class _SmoothTextSwitcherState extends State<SmoothTextSwitcher> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
      _startAnimation();
    });
  }

  @override
  void didUpdateWidget(covariant SmoothTextSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.texts != widget.texts) {
      _resetAnimation();
      _startAnimation();
    }
  }

  void _resetAnimation() {
    _timer?.cancel();
    _currentIndex = 0;
  }


  void _startAnimation() {
    if (widget.texts.isEmpty || !_initialized || _timer != null) return;

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted || widget.texts.isEmpty) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
      });




    });
    _timer= Timer(const Duration(seconds: 6), () {
      if (!mounted || widget.texts.isEmpty) return;

      setState(() {
        _currentIndex = 0;
      });
      // 清理定时器确保只执行一次
      _timer?.cancel();
      _timer = null;
    });



  }




  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || widget.texts.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        widget.texts[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 34.sp
        ),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
