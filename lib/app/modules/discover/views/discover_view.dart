import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';
import '../controllers/discover_controller.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommAppbar(
      slivers: [
        // 歌单列表
        _buildHorizontalSection(
          title: "歌单列表",
          itemBuilder: (context, index) => _buildImageCard(),
          itemCount: 11, // str.split("").length
        ),
        // 最受欢迎
        _buildHorizontalSection(
          title: "最受欢迎",
          itemBuilder: (context, index) => _buildSongTile(),
          itemCount: 11,
        ),
        // 排行榜
        _buildHorizontalSection(
          title: "排行榜",
          itemBuilder: (context, index) => _buildRankingCard(),
          itemCount: 11,
        ),
      ],
    );
  }

  // 通用横向滚动区块构建方法
  SliverToBoxAdapter _buildHorizontalSection({
    required String title,
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 12.w,
            ),
            SizedBox(
              height: _getSectionHeight(title),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 根据区块类型返回预估高度
  double _getSectionHeight(String title) {
    switch (title) {
      case "歌单列表":
        return 200.w; // 图片卡片高度
      case "最受欢迎":
        return 450.w; // 歌曲列表项高度
      case "排行榜":
        return 560.w; // 排行榜卡片高度
      default:
        return 200.w;
    }
  }

  // 图片卡片组件
  Widget _buildImageCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: SizedBox(
        width: 160.w,
        height: 160.w,
        child: Image.network(
          "https://img.moegirl.org.cn/common/thumb/c/c5/2020ismlhuangyu1.png/89px-2020ismlhuangyu1.png",
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  // 歌曲列表项组件
  Widget _buildSongTile() {
    return SizedBox(
      width: 600.w,
      child: Column(
        children: List.generate(

          3,
              (index) => ListTile(
            leading: _buildNetworkImage(120.w),
            title: Text(
              "BAK SONG ss..",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text("ly-nsiwls"),
            trailing: Icon(Icons.headphones_rounded, size: 28.w),
          ),
        ),
      ),
    );
  }

  // 排行榜卡片组件
  Widget _buildRankingCard() {
    return Container(
       decoration: BoxDecoration(
         color: Colors.grey.shade50,
         borderRadius: BorderRadius.all(Radius.circular(18.w))
       ),
      padding: EdgeInsets.all(10),
      width: 650.w,
      height: 580.w,
     
        child: Column(
         
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero, // 移除内边距
              leading: SizedBox(
                width: 260.w,
                child: Row(
                  children: [
                    Text("流行榜单", style: TextStyle(fontSize: 34.sp)),
                    const Spacer(),
                    Icon(Icons.play_circle, size: 44.w),
                  ],
                ),
              ),
              trailing: Text("11.1.1 更新", style: TextStyle(fontSize: 34.sp)),
            ),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 1,),
                itemBuilder: (_, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _buildNetworkImage(180.w),
                  title: Text(
                    "时崎狂三-魔术侦探. BAK SONG ss..",
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text("ly-nsiwls"),
                  trailing: Icon(Icons.headphones_rounded, size: 28.w),
                ),
              ),
            ),
          ],
        ),
       
    );
  }

  // 通用图片加载组件
  Widget _buildNetworkImage(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.w),
      child: Image.network(
        "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}



