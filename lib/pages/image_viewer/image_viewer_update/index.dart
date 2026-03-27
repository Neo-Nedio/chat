import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import '../../../components/custom_button/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

//展示单个图片，点击可以对图片更新
class ImageViewerUpdatePage extends CustomWidget<ImageViewerUpdateLogic> {
  ImageViewerUpdatePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),  // 返回按钮白色
        backgroundColor: Colors.black,                        // 黑色背景
      ),
      //主体内容
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //图片显示区域
            Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4, // 占屏幕高度的 40%
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Obx( //当用户更换图片后，imageUrl 变化，图片自动更新。
                        () => PhotoView(
                      minScale: PhotoViewComputedScale.contained * 0.5,  // 最小缩放 0.5 倍
                      maxScale: PhotoViewComputedScale.covered * 2,      // 最大缩放 2 倍
                      imageProvider: NetworkImage(controller.imageUrl.value),  // 网络图片
                    ),
                  ),
                ),
            ),

            const SizedBox(height: 30),

            // 动态按钮（文字可变化）
            Obx(
                  () {
                if (controller.isUpdate.value) {
                  return Column(
                    children: [
                      CustomButton(
                        text: controller.text.value,
                        onTap: () => _showDialog(context),
                        width: MediaQuery.of(context).size.width / 2,
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 15),

            // 固定按钮
            CustomButton(
              text: '保存图片',
              onTap: () => controller.saveImage(),
              type: 'minor',
              width: MediaQuery.of(context).size.width / 2,
            ),
          ],
        ),
      ),
    );
  }

  //选择图片对话框
  void _showDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('图库'),
              onTap: () => controller.cropChatBackgroundPicture(null),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () =>
                  controller.cropChatBackgroundPicture(ImageSource.camera),
            ),
          ],
        );
      },
    );
  }
}
