import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mobile/components/custom_material_button/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../api/user_api.dart';

final _userApi = UserApi();

//图片加载
/*
┌─────────────────────────────────────────────────────────────────┐
│  CustomImageGroup                                               │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ imagesList = ['id1', 'id2', 'id3']                         ││
│  │ imageUrls = ['', '', ''] (初始化)                           ││
│  └─────────────────────────────────────────────────────────────┘│
│                              ↓                                  │
│  GridView.builder 渲染 3 个图片                                 │
│                              ↓                                  │
│  每个图片使用 FutureBuilder                                     │
│                              ↓                                  │
│  调用 onGetImg('id1', userId, 0)                               │
│                              ↓                                  │
│  API 请求: _userApi.getImg('id1', userId)                      │
│                              ↓                                  │
│  返回: 'https://xxx.com/img1.jpg'                              │
│                              ↓                                  │
│  imageUrls[0] = 'https://xxx.com/img1.jpg' (保存)              │
│                              ↓                                  │
│  CachedNetworkImage 显示图片                                    │
│                              ↓                                  │
│  用户点击图片                                                   │
│                              ↓                                  │
│  _handlerOpenImageViewer(0)                                    │
│                              ↓                                  │
│  Get.toNamed('/image_viewer', arguments: {                     │
│    'imageUrls': ['https://...', 'https://...', 'https://...'], │
│    'currentIndex': 0                                           │
│  })                                                            │
└─────────────────────────────────────────────────────────────────┘*/
class CustomImageGroup extends StatelessWidget {
  final List<dynamic> imagesList;  // 图片ID列表（如 ['img001', 'img002']）
  final String userId;              // 用户ID
  List<String> imageUrls = [];      // 真实的图片URL列表（会被填充）

  CustomImageGroup({
    super.key,
    required this.imagesList,
    required this.userId,
  }) : imageUrls = List.filled(imagesList.length, ''); //初始化列表

  //跳转到图片页(进行操作)
  void _handlerOpenImageViewer(index) async{
    // 如果当前图片 URL 为空，等待加载（防止还没加载出来前点击，造成错误）
    if (imageUrls[index].isEmpty) {
      // 手动触发加载
      await onGetImg(imagesList[index], userId, index);
    }
    Get.toNamed('/image_viewer',
        arguments: {'imageUrls': imageUrls, 'currentIndex': index});
  }

  //获取图片url
  Future<String> onGetImg(String fileName, String userId, int index) async {
    dynamic res = await _userApi.getImg(fileName, userId);
    if (res['code'] == 0) {
      imageUrls[index] = res['data']; // 缓存到列表
      return res['data'];
    }
    return '';
  }

  Widget _buildTalkImage(String imageStr, String userId,  int index) {
    return CustomMaterialButton(
        onTap: () => _handlerOpenImageViewer(index), // 点击跳转
        child: Container(
          padding: const EdgeInsets.all(2.0),
          child: FutureBuilder<String>(
            future: onGetImg(imageStr, userId,index), //获取图片url
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CachedNetworkImage(
                  imageUrl: snapshot.data ?? '',
                  fit: BoxFit.cover,
                  //加载中
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffffffff),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  //失败图片
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/empty-bg.png'),
                );
              } else {
                //加载或失败
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffffffff),
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
            },
          ),
        ),
    );
  }

  Widget _buildImageGrid(List<dynamic> imageUrls, String userId) {
    return GridView.builder(
      shrinkWrap: true,  // 根据内容收缩高度
      physics: const NeverScrollableScrollPhysics(), // 禁止网格自身滚动
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,      // 每行3列
        crossAxisSpacing: 0,    // 列间距0
        mainAxisSpacing: 0,     // 行间距0
        childAspectRatio: 1.0,  // 宽高比1:1
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildTalkImage(imageUrls[index], userId, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildImageGrid(imagesList, userId);
  }
}
