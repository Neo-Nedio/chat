import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/user_api.dart';

final _userApi = UserApi();

//图片加载
class CustomImageGroup extends StatelessWidget {
  final List<dynamic> imagesList;
  final String userId;

  const CustomImageGroup({
    super.key,
    required this.imagesList,
    required this.userId,
  });

  //获取图片url
  Future<String> onGetImg(String fileName, String userId) async {
    dynamic res = await _userApi.getImg(fileName, userId);
    if (res['code'] == 0) {
      return res['data'];
    }
    return '';
  }

  Widget _buildTalkImage(String imageStr, String userId) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: FutureBuilder<String>(
        future: onGetImg(imageStr, userId), //获取图片url
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
        return _buildTalkImage(imageUrls[index], userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildImageGrid(imagesList, userId);
  }
}
