import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../components/app_bar_title/index.dart';
import '../../../../components/custom_button/index.dart';
import '../../../../components/custom_material_button/index.dart';
import '../../../../components/custom_text_button/index.dart';
import '../../../../components/custom_text_field/index.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';


class SetGroupPage extends CustomWidget<SetGroupLogic> {
  SetGroupPage({super.key});

  void _showAddGroupDialog(BuildContext context) {
/*
    ┌─────────────────────────────────┐
    │         添加分组                 │
    │    请填写新的分组名称            │
    │                                 │
    │  ┌─────────────────────────┐   │
    │  │ 分组名称            0/10│   │
    │  └─────────────────────────┘   │
    │                                 │
    │  ┌──────────┐  ┌──────────┐   │
    │  │   确定   │  │   取消   │   │
    │  └──────────┘  └──────────┘   │
    └─────────────────────────────────┘*/
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
              mainAxisSize: MainAxisSize.min,  // 高度自适应
              children: [
                // 标题
                Text(
                  '添加分组',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),

                const SizedBox(height: 5),

                // 提示文字
                const Text(
                  '请填写新的分组名称',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // 输入框
                CustomTextField(
                  vertical: 8,
                  controller: controller.groupController,
                  inputLimit: 10,
                  hintText: "分组名称",
                  suffix: Text('${controller.groupController.text.length}/10'),
                ),

                const SizedBox(height: 20),

                // 按钮行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: '确定',
                        onTap: () => controller.onAddGroup(context),
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
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      //标题
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const AppBarTitle('好友分组'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          //右上角按钮
          actions: [
            CustomTextButton('添加',
                onTap: () => _showAddGroupDialog(context),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                fontSize: 14),
          ]),

      //主体内容
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //分组列表
              ...controller.groupList.map(
                (group) =>Column(
                    children: [
                    //自定义有涟漪效果的按钮
                    CustomMaterialButton(
                      onTap: () => controller.onSetGroup(group),
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
                            //分组名字
                            Expanded(
                              child: Text(
                                group['label'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            //是否选中
                            if (controller.selectedGroup == group['label'])
                              Icon(Icons.check,
                                  color: theme.primaryColor, size: 24)
                          ],
                        ),
                      ),
                    ),
                    //分割线
                    const SizedBox(height: 1)
                   ]
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
