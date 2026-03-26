import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../components/app_bar_title/index.dart';
import '../../../../components/custom_button/index.dart';
import '../../../../components/custom_material_button/index.dart';
import '../../../../components/custom_text_button/index.dart';
import '../../../../components/custom_text_field/index.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';


class SetGroupPage extends CustomWidgetNew<SetGroupLogic> {
  SetGroupPage({super.key});

  //添加或修改分组弹窗（右上角或通过底部弹窗触发）
  void showAddAndUpdateGroupDialog(
      BuildContext context, {
        dynamic group,
        String? title = "添加分组",
        String? label = '请填写新的分组名称',
        String? hintText = '分组名称',
      }) =>
      showDialog(
        context: context,
        barrierDismissible: false, // 设置为 false 禁止点击外部关闭弹窗
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //标题
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  //内容
                  Text(
                    label!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  //输入框
                  CustomTextField(
                    vertical: 8,
                    controller: controller.groupController,
                    inputLimit: 10,
                    hintText: hintText!,
                    suffix:
                    Text('${controller.groupController.text.length}/10'),
                  ),
                  const SizedBox(height: 20),
                  //确认与取消按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: '确定',
                          onTap: () => controller.onADDorUpdateGroup(context, group),
                          width: 120,
                          height: 34,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: '取消',
                          onTap: () => Navigator.of(context).pop(),
                          type: 'minor',
                          height: 34,
                          width: 120,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  //底部弹窗（长按触发）
  void _showGroupBottomSheet(BuildContext context, dynamic group) =>
      Get.bottomSheet(
        backgroundColor: Colors.white,
        Wrap(
          children: [
            //重新命名按钮
            Center(
              child: TextButton(
                //最终会打开 添加或修改分组弹窗（showAddAndUpdateGroupDialog）
                //传入group，代表更新分组
                onPressed: ()=>controller.onUpdateGroupPress(context,group),
                child: Text(
                  '重新命名',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ),
            //删除按钮
            Center(
              child: TextButton(
                onPressed: () => controller.onDeleteGroup(group),
                child: const Text(
                  '删除分组',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget buildWidget(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FBFF),
    appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppBarTitle('好友分组'),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          //右上角添加按钮
          CustomTextButton('添加',
              //不传入group，代表创建分组
              onTap: () => showAddAndUpdateGroupDialog(context),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 5.0),
              fontSize: 14),
        ]),

    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...controller.groupList.map(
                  (group) => Column(
                children: [
                  CustomMaterialButton(
                    onLongPress: () => //长按触发底部弹窗
                        _showGroupBottomSheet(context, group),
                    onTap: () => controller.onSetGroup(group), //点击设置分组（当从好友信息页进入时可触发）
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              group['label'],
                              style: const TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          //当selectedGroup不为0，即不从好友信息页进入时根据选择触发选中图标
                          if (controller.selectedGroup == group['label'])
                            Icon(Icons.check,
                                color: theme.primaryColor, size: 24)
                        ],
                      ),
                    ),
                  ),
                  //间隔
                  const SizedBox(height: 1)
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

