import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class CreateChatGroupPage extends CustomWidget<CreateChatGroupLogic> {
  CreateChatGroupPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const AppBarTitle('创建群聊'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          //右上角完成按钮
          actions: [
            CustomTextButton('完成',
                onTap: controller.onCreateChatGroup,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                fontSize: 14),
          ]),

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CustomTextField(
              labelText: "群名称",
              controller: controller.nameController,
              inputLimit: 10,
              hintText: "请输入群名称~",
              onChanged: controller.onGroupNameChanged,
              suffix: Text('${controller.nameLength}/10'),
            ),
          ],
        ),
      ),
    );
  }
}
