import 'package:flutter/material.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_button/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class AdminNotifyPage extends CustomWidget<AdminNotifyLogic> {
  AdminNotifyPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarTitle('发布通知'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text('标题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: '请输入通知标题',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 8),

            // 图片选择器
            const Text('图片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => controller.showImagePicker(context),
              child: controller.selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        controller.selectedImage!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF2F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // 内容
            const Text('内容', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.textController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '请输入通知内容',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 24),

            // 提交按钮
            Center(
              child: controller.isSubmitting
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: '发布通知',
                      onTap: () => controller.onSubmit(),
                      width: MediaQuery.of(context).size.width - 32,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
