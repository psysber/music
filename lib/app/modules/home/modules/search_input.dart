import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxHeight: double.infinity, maxWidth: 200),
      child: TextField(
        readOnly: true,
        onTap: () {
          print("jump");
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
          hintText: '请输入搜索内容',
          prefixIcon: Icon(Icons.search),
          // contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.withAlpha(100))),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
