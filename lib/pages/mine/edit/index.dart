import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../components/custom_update_portrait/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class EditMinePage extends CustomWidget<EditMineLogic> {
  EditMinePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    //屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient( //渐变
            colors: [theme.minorColor, const Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // 返回按钮
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: ()=>Get.back(), icon: const Icon(Icons.arrow_back))
                    ],
                  ),

                  const Spacer(flex: 1),

                  //头像
                  CustomUpdatePortrait(
                      isEdit: controller.isEdit,
                      onTap: () => controller.selectPortrait(),
                      url: controller.currentUserInfo['portrait'] ?? '',
                      size: 80,
                      radius: 50),

                  const SizedBox(height: 16),

                  //性别选择器
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, //居中
                      children: [
                        //男生按钮
                        GestureDetector(
                          onTap: () => controller.setSex('男'),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: controller.maleColorActive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.male,
                                  size: 20,
                                  color: controller.maleTextColorActive,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '男生',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: controller.maleTextColorActive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //左右间隔
                        const SizedBox(width: 30),

                        //女生按钮
                        GestureDetector(
                          onTap: () => controller.setSex('女'),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: controller.femaleColorActive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.female,
                                  size: 20,
                                  color: controller.femaleTextColorActive,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '女生',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: controller.femaleTextColorActive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //上下间隔
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color(0xFFF2F2F2),
                        width: 1.0,
                      ),
                    ),
                    child: Column(children: [
                      // 昵称输入框
                      CustomTextField(
                        labelText: "昵称",
                        controller: controller.nameController,
                        inputLimit: 30,
                        onChanged: controller.onNameTextChanged,
                        readOnly: !controller.isEdit,//根据是否开始编辑.达成是否可读
                        suffix: Text('${controller.nameTextLength}/30'),
                      ),

                      //上下间隔
                      const SizedBox(height: 10),

                      //生日选择器
                      CustomTextField(
                        labelText: "生日",
                        controller: controller.birthdayController,
                        readOnly: true,
                        suffixIcon: IconButton( //设定右侧可点击图标
                          onPressed: () => controller.selectDate(context),
                          icon: const Icon(Icons.calendar_today, size: 20),
                        ),
                      ),

                      //上下间隔
                      const SizedBox(height: 10),

                      //签名输入框
                      CustomTextField(
                        labelText: "签名",
                        controller: controller.signatureController,
                        inputLimit: 100,
                        onChanged: controller.onSignatureTextChanged,
                        readOnly: !controller.isEdit,//根据是否开始编辑.达成是否可读
                        maxLines: 4,
                        suffix: Text('${controller.signatureTextLength}/100'),
                      ),
                    ]
                    ),
                  ),



                  const SizedBox(height: 16),

                  //按钮
                  CustomButton(
                    text: !controller.isEdit?"编辑资料":"保存",
                    onTap: controller.onPressed,
                    width: MediaQuery.of(context).size.width,
                    type: 'gradient',
                  ),

                  const Spacer(flex: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
