import 'package:flutter/material.dart';

import '../../api/notify_api.dart';
import '../app_loading.dart';
import '../CustomDialog/index.dart';
import '../custom_flutter_toast/index.dart';
import '../custom_image/index.dart';

//系统通知展示
class CustomNotifyContent extends StatelessWidget {
  static final Map<String, String> _urlCache = {};
  static final NotifyApi _notifyApi = NotifyApi();

  final String title;
  final String text;
  final String imgFileName;
  final double titleSize;
  final double textSize;
  final bool showDelete;
  final String notifyId;
  final VoidCallback? update;

  const CustomNotifyContent({
    super.key,
    required this.title,
    required this.text,
    required this.imgFileName,
    required this.notifyId,
    this.titleSize = 18,
    this.textSize = 14,
    this.showDelete = false, //是否展示删除按钮
    this.update //删除后更新页面
  });

  factory CustomNotifyContent.fromNotify(
    Map<String, dynamic> notify, {
    double titleSize = 18,
    double textSize = 14,
    bool showDelete = false,
    VoidCallback? update
  }) {
    final content = notify['content'] ?? {};
    return CustomNotifyContent(
      title: content['title']?.toString() ?? '',
      text: content['text']?.toString() ?? '',
      imgFileName: content['img']?.toString().trim() ?? '',
      notifyId: notify['id'] ?? '',
      titleSize: titleSize,
      textSize: textSize,
      showDelete : showDelete,
      update: update,
    );
  }

  Future<void> onDelete()async {
    _notifyApi.deleteNotify(notifyId).then((res){
      if(res['code'] == 0){
        CustomFlutterToast.showSuccessToast('删除成功');
        update?.call(); //不为空时调用
      }else{
        CustomFlutterToast.showErrorToast(res['msg'] ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
    children: [
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //标题
        if (title.isNotEmpty)
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 10),

        //内容
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

        //图片
        if (imgFileName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildImage(),
          ),
      ],
    ),
    //右上角删除按钮
    if (showDelete)
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () =>{
              CustomDialog.showTipDialog(
                  context,
                  text: '删除通知',
                  onOk: onDelete,
                  onCancel: () =>{}
              )
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
        ),
        )
  ]);
  }

  //获取图片url
  Future<String> _getImgUrl() async {
    final key = imgFileName.trim();
    if (key.isEmpty) return '';
    if (_urlCache.containsKey(key)) return _urlCache[key]!;
    final res = await _notifyApi.getImgUrl(key);
    if (res['code'] == 0 && res['data'] != null) {
      final url = res['data'].toString().trim();
      if (url.isNotEmpty) {
        _urlCache[key] = url;
        return url;
      }
    }
    return '';
  }

  //构建图片
  Widget _buildImage() {
    return FutureBuilder<String>(
      future: _getImgUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: 80,
            child: Center(
              child: appLoadingInkDrop(
                color: const Color(0xFF9E9E9E),
                size: 28,
              ),
            ),
          );
        }
        if (snapshot.hasError || (snapshot.data ?? '').isEmpty) {
          return Image.asset('assets/images/empty-image.png');
        }
        return CustomImage(url: snapshot.data!);
      },
    );
  }
}
