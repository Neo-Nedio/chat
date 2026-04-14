import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/msg_api.dart';
import '../../../components/custom_image/index.dart';
import '../../../utils/getx_config/config.dart';

class ImageMessage extends StatelessThemeWidget {
  final _msgApi = MsgApi();
  final dynamic value;
  final bool isRight;

  ImageMessage({
    super.key,
    required this.value,
    required this.isRight,
  });

  Future<String> onGetImg() async {
    dynamic res = await _msgApi.getMedia(value['id']);
    if (res['code'] == 0) {
      return res['data'];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final maxSize = MediaQuery.of(Get.context!).size.width * 0.4;
    return ConstrainedBox(
      //限制最大宽高，而不是直接用container设置宽高，这样可以让图片自由匹配比例
      constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
      child: FutureBuilder<String>(
        future: onGetImg(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomImage(url: snapshot.data ?? '');
          } else {
            return Container(
              width: maxSize,
              color: isRight ? theme.primaryColor : Colors.white,
              height: maxSize,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 40,
                height: 40,
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
}
