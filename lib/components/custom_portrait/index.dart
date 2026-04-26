import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../api/user_api.dart';
import '../app_loading.dart';

final _userApi = UserApi();
// 使用 Map 存储多个头像的URL缓存
final Map<String, String> _urlCache = {};

// 供 [CustomPortrait]、[CustomUpdatePortrait] 共用，避免重复请求与双份缓存。
Future<String> resolvePortraitUrl(String fileName) async {
  final key = fileName.trim();
  if (key.isEmpty) return '';
  if (_urlCache.containsKey(key)) {
    return _urlCache[key]!;
  }
  final res = await _userApi.getPortrait(key);
  if (res['code'] == 0 && res['data'] != null) {
    final url = res['data'].toString().trim();
    if (url.isNotEmpty) {
      _urlCache[key] = url;
      return url;
    }
  }
  return '';
}

//自定义头像组件
class CustomPortrait extends StatelessWidget {
  final double size;
  final String portrait;
  final double radius;
  final VoidCallback? onTap;
  final bool openImage;//是否可以点击指向图片查看器，true时onTap无效
  final bool? isGreyColor; //是否在头像上叠加一个半透明灰色遮罩

  const CustomPortrait({
    super.key,
    this.size = 50,
    required this.portrait,
    this.radius = 25,
    this.onTap,
    this.openImage = false,
    this.isGreyColor = false,
  });

  void onOpenImage(String url) {
    Get.toNamed('/image_viewer_update', arguments: {
      'imageUrl': url,
      'isUpdate': false,
    });
  }

  //获取图片url
  Future<String> onGetImg(String fileName) => resolvePortraitUrl(fileName);

  @override
  Widget build(BuildContext context) {
    //无存储
    if (portrait.trim().isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            'assets/images/default-portrait.jpeg',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return  Container(
        padding: const EdgeInsets.all(2.0),
        child: FutureBuilder<String>(
          future: onGetImg(portrait), //获取图片url
          builder: (context, snapshot) {
            // 失败时 future 得到 ''，hasData 仍为 true，不能交给 CachedNetworkImage
            if (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)) {
              return GestureDetector(
                  onTap: openImage
                      ? () => onOpenImage(snapshot.data ?? '')
                      : onTap, //回调函数
                  child: Stack(
                    children: [
                      ClipRRect(
                        // 圆角头像
                        borderRadius: BorderRadius.circular(radius),
                        child: CachedNetworkImage(
                          // 缓存网络图片
                          imageUrl: snapshot.data ?? '', // 头像URL
                          width: size,
                          height: size,
                          fit: BoxFit.cover, // 图片铺满整个区域
                          // 图片加载时的占位组件
                          placeholder: (context, url) => Container(
                            width: size,
                            height: size,
                            color: Colors.grey[300],
                            child: Center(
                              child: appLoadingInkDrop(
                                color: const Color(0xffffffff),
                                size: (size * 0.5).clamp(16.0, 28.0),
                              ),
                            ),
                          ),
                          // 图片加载失败时的占位组件
                          errorWidget: (context, url, error) => Container(
                            width: size,
                            height: size,
                            color: Colors.grey[300], // 灰色背景
                            child: Image.asset('assets/images/default-portrait.jpeg'),
                          ),
                        ),
                      ),

                      //在头像上叠加一个半透明灰色遮罩
                      Opacity(
                        opacity: isGreyColor == true ? 0.5 : 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Container(
                            width: size,
                            height: size,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  )
              );
            } else if (snapshot.connectionState == ConnectionState.waiting){
              //加载
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: appLoadingInkDrop(
                    color: const Color(0xffffffff),
                    size: (size * 0.5).clamp(16.0, 28.0),
                  ),
                ),
              );
            }
            else{ //失败
              return GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Image.asset(
                    'assets/images/default-portrait.jpeg',
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          },
        ),
    );
  }
}
