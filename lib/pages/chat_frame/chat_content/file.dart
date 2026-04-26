import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/msg_api.dart';
import '../../../components/app_loading.dart';
import '../../../utils/String.dart';
import '../../../utils/getx_config/config.dart';

//文件消息组件，用于在聊天界面显示文件（如文档、图片、压缩包等）的预览卡片。
class FileMessage extends StatelessThemeWidget {
  final _msgApi = MsgApi();
  final dynamic value;   // 消息对象
  final bool isRight;    // 是否是自己发的

  FileMessage({
    super.key,
    required this.value,
    required this.isRight,
  });

  //获取文件url
  Future<String> onGetFile() async {
    dynamic res = await _msgApi.getMedia(value['id']);
    if (res['code'] == 0) {
      return res['data'];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────┐
    │  ┌─────────────────────────────────────────────┐│
    │  │  工作报告.docx                               ││
    │  │  1.2 MB                            📄 DOC  ││
    │  └─────────────────────────────────────────────┘│
    └─────────────────────────────────────────────────┘*/
    dynamic content = jsonDecode(value['msgContent']['content']);

    return SizedBox(
      height: 85,
      child: FutureBuilder<String>(
        future: onGetFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              //点击后去文件详情页
              onTap: () {
                Get.toNamed('file_details', arguments: {
                  'fileUrl': snapshot.data,
                  'fileName': content['name'],
                  'fileType': content['type'],
                  'fileSize': content['size'],
                });
              },
              child: Container(
                height: 80,                             // 固定高度
                padding: const EdgeInsets.all(10),      // 内边距
                decoration: BoxDecoration(
                  color: isRight ? theme.primaryColor : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(Get.context!).size.width * 0.6, // 最大宽度 60%
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, //水平两端
                  crossAxisAlignment: CrossAxisAlignment.center,     //竖直中央
                  children: [
                    //左侧文字区域
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //名字
                          Text(
                            maxLines: 2,                              // 最多2行
                            content['name'],                          // 文件名
                            style: TextStyle(
                                color: isRight ? Colors.white : null,
                                overflow: TextOverflow.ellipsis),  // 超出显示省略号
                          ),

                          const SizedBox(height: 2),

                          //大小
                          Text(
                            StringUtil.formatSize(content['size']), // 格式化文件大小
                            style: TextStyle(
                                color: isRight ? Colors.white : null, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    //右侧图标区域
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // 背景图标
                        Image.asset(
                          isRight
                              ? 'assets/images/file-white.png'           // 自己：白色图标
                              : 'assets/images/file-${theme.themeMode}.png', // 对方：根据主题颜色
                          width: 50,
                        ),
                        Transform.translate(
                          offset: const Offset(-2, 2), // 偏移位置，让文字看起来在图标上
                          child: Text(
                            content['type'].toUpperCase(), // 文件类型（如 DOCX, PDF）
                            style: TextStyle(
                                color: isRight ? theme.primaryColor : Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            //加载中（固定尺寸占位）
            return Container(
              width: MediaQuery.of(Get.context!).size.width * 0.6,
              color: isRight ? theme.primaryColor : Colors.white,
              height: 85,
              alignment: Alignment.center,
              child: appLoadingInkDrop(
                color: const Color(0xffffffff),
                size: 40,
              ),
            );
          }
        },
      ),
    );
  }
}
