import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/custom_button/index.dart';
import '../../utils/String.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

//文件详情页
class FileDetailsPage extends CustomWidget<FileDetailsLogic> {
  FileDetailsPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件详情'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 80),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              //文件图片与类型
              Stack(
                alignment: Alignment.center,
                //文件图片
                children: [
                  Image.asset(
                    'assets/images/file-${theme.themeMode}.png',
                    width: 70,
                  ),
                  //文件类型
                  Transform.translate(
                    offset: const Offset(-3, 3),
                    child: Text(
                      controller.fileType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              //文件名
              Text(controller.fileName, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 8),

              //文件大小
              Text(
                '文件大小：${StringUtil.formatSize(controller.fileSize)}',
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 15),

              //下载完成后显示
              if (controller.isDownloaded)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomButton(text: '用其他应用打开', onTap: controller.openFile)
                  ],
                )
              else
                //下载没完成时
                Obx(() {
                  //没开始下载
                  if (!controller.isDownloading.value) {
                    // 开始下载按钮
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        CustomButton(
                          text: '开始下载',
                          onTap: controller.startDownload,
                        ),
                      ],
                    );
                  } else {
                    //开始下载
                    return Column(
                      children: [
                        //线性进度指示器
                        LinearProgressIndicator(
                          minHeight: 5,
                          value: controller.downloadProgress.value,
                          color: theme.primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        const SizedBox(height: 5),
                        CustomButton(
                          text: '取消下载',
                          onTap: controller.cancelDownload,
                        ),
                      ],
                    );
                  }
                }),
            ],
          ),
        ),
      ),
    );
  }
}
