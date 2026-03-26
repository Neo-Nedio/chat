import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_label_value_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../utils/String.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class TalkCreatePage extends CustomWidget<TalkCreateLogic> {
  TalkCreatePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                         TalkCreatePage                                  │
    │                         (发表说说页面)                                   │
    ├─────────────────────────────────────────────────────────────────────────┤
    │                                                                         │
    │  ┌─────────────────────────────────────────────────────────────────┐   │
    │  │                         AppBar                                   │   │
    │  │  ┌────────────────────────────────────────────────────────────┐ │   │
    │  │  │  [←]           发表说说                    [确定]          │ │   │
    │  │  └────────────────────────────────────────────────────────────┘ │   │
    │  └─────────────────────────────────────────────────────────────────┘   │
    │                                                                         │
    │  ┌─────────────────────────────────────────────────────────────────┐   │
    │  │  Container (padding: 8)                                         │   │
    │  │  ┌───────────────────────────────────────────────────────────┐ │   │
    │  │  │  SingleChildScrollView                                    │ │   │
    │  │  │  ┌─────────────────────────────────────────────────────┐ │ │   │
    │  │  │  │  Column                                            │ │ │   │
    │  │  │  │  ┌───────────────────────────────────────────────┐ │ │ │   │
    │  │  │  │  │  1. 文本输入框                                │ │ │ │   │
    │  │  │  │  │  ┌─────────────────────────────────────────┐ │ │ │ │   │
    │  │  │  │  │  │  记录当前时刻...                        │ │ │ │ │   │
    │  │  │  │  │  └─────────────────────────────────────────┘ │ │ │ │   │
    │  │  │  │  └───────────────────────────────────────────────┘ │ │ │   │
    │  │  │  │                                                   │ │ │   │
    │  │  │  │  SizedBox(height: 5)                              │ │ │   │
    │  │  │  │                                                   │ │ │   │
    │  │  │  │  2. 图片网格区域 (Obx)                            │ │ │   │
    │  │  │  │  ┌─────────────────────────────────────────────┐ │ │ │   │
    │  │  │  │  │  ┌─────┐ ┌─────┐ ┌─────┐                   │ │ │ │   │
    │  │  │  │  │  │     │ │     │ │  +  │                   │ │ │ │   │
    │  │  │  │  │  └─────┘ └─────┘ └─────┘                   │ │ │ │   │
    │  │  │  │  └─────────────────────────────────────────────┘ │ │ │   │
    │  │  │  │                                                   │ │ │   │
    │  │  │  │  SizedBox(height: 5)                              │ │ │   │
    │  │  │  │                                                   │ │ │   │
    │  │  │  │  3. 可见权限设置 (CustomLabelValueButton)         │ │ │   │
    │  │  │  │  ┌─────────────────────────────────────────────┐ │ │ │   │
    │  │  │  │  │  谁可以看        [头像]张三 [头像]李四   >  │ │ │ │   │
    │  │  │  │  └─────────────────────────────────────────────┘ │ │ │   │
    │  │  │  └─────────────────────────────────────────────────────┘ │ │   │
    │  │  └───────────────────────────────────────────────────────────┘ │   │
    │  └─────────────────────────────────────────────────────────────────┘   │
    │                                                                         │
    └─────────────────────────────────────────────────────────────────────────┘*/
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      //导航栏
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarTitle('发表说说'),
        backgroundColor: const Color(0xFFF9FBFF),
        //发布按钮
        actions: [
          CustomTextButton('确定',
              onTap: controller.onCreateTalk,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              fontSize: 14),
        ],
      ),
      //主体内容
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //文本输入框
              CustomTextField(
                hintText: '记录当前时刻...',
                controller: controller.contentController,
                maxLines: 4,
                hintTextColor: theme.primaryColor,
              ),

              const SizedBox(height: 5),

              // 图片网格展示区域(响应式)
              Obx(() => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,        // 每行3列
                          mainAxisSpacing: 8,       // 垂直间距8px
                          crossAxisSpacing: 8,      // 水平间距8px
                    ),
                    itemCount: controller.selectedImages.length < 9
                        ? controller.selectedImages.length + 1  // 显示添加按钮
                        : 9,                                     // 最多9张
                    itemBuilder: (context, index) {
                      //// 添加按钮（最后一位）
                      // 如果是最后一个位置且图片数量小于9，显示添加按钮
                      if (index == controller.selectedImages.length &&
                          controller.selectedImages.length < 9) {
                        return GestureDetector(
                          onTap: controller.pickImages, //点击添加图片
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF2F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined, //加号图标
                              size: 32,
                              color: Colors.grey, //灰色背景
                            ),
                          ),
                        );
                      }
                      // 显示已选择的图片
                      return Stack(
                        children: [
                          // 图片
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image:
                                    FileImage(controller.selectedImages[index]), // 本地文件
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // 删除按钮（右上角）
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon( //白色删除按钮
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )),

              const SizedBox(height: 5),

              //可见权限设置
              CustomLabelValueButton(
                label: '谁可以看',
                color: const Color(0xFFEDF2F9),
                onTap: controller.handlerToUserSelect,
                //hint: controller.selectedUsers.isNotEmpty ? '已选中的用户' : '所有人可见',
                width: 80,
                child: controller.selectedUsers.isEmpty
                    //没有选中用户（所有人可见）
                    ? const Text(
                        '所有人可见',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                      )
                    //已选中用户
                    : Wrap(
                        spacing: 2.0,      // 水平间距2px
                        runSpacing: 2.0,   // 垂直间距2px
                        children: [
                          ...controller.selectedUsers
                              .map((user) => _buildUserItem(user)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //用户组件
  Widget _buildUserItem(user) {
    return Container(
      height: 26,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: theme.primaryColor.withValues(alpha: 0.5), width: 1),
        color: theme.searchBarColor,
      ),
      constraints: const BoxConstraints(maxWidth: 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPortrait(
            //头像
            url: user['portrait'] ?? '',
            size: 16,
          ),
          const SizedBox(width: 2),
          //昵称
          Expanded(
            child: Text(
              StringUtil.isNotNullOrEmpty(user['remark'])
                  ? user['remark']
                  : user['name'],
              style: const TextStyle(
                  fontSize: 12, overflow: TextOverflow.ellipsis),
            ),
          )
        ],
      ),
    );
  }
}
