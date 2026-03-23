import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../components/custom_text_button/index.dart';
import '../../../../components/custom_text_field/index.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';

class SetRemarkPage extends CustomWidget<SetRemarkLogic> {
  SetRemarkPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      //头部
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('好友备注'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            //完成按钮
            CustomTextButton('完成',
                onTap: controller.onSetRemark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                fontSize: 14),
          ]),
      //主体内容
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [

            const SizedBox(height: 30),

            CustomTextField(
              labelText: "备注",
              controller: controller.remarkController,
              inputLimit: 10,
              hintText: "请输入用户备注~",
              onChanged: controller.onRemarkChanged,
              suffix: Text('${controller.remarkLength}/10'),
            ),
          ],
        ),
      ),
    );
  }
}
