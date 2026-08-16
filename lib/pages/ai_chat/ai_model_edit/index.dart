import 'package:flutter/material.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

//AI 模型编辑页（新增 / 编辑双模式）
class AiModelEditPage extends CustomWidget<AiModelEditLogic> {
  AiModelEditPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF9FBFF),
        title: AppBarTitle(controller.isEdit ? '编辑模型' : '添加模型'),
        //提交按钮
        actions: [
          CustomTextButton(
            '确定',
            onTap: controller.submit,
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            fontSize: 14,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //显示名
              CustomTextField(
                labelText: '显示名',
                hintText: '如：我的GPT',
                controller: controller.modelNameController,
                hintTextColor: theme.primaryColor,
              ),
              const SizedBox(height: 16),

              //接口地址
              CustomTextField(
                labelText: '接口地址',
                hintText: '如：https://api.openai.com/v1',
                controller: controller.baseUrlController,
                hintTextColor: theme.primaryColor,
              ),
              const SizedBox(height: 16),

              //ApiKey（编辑模式留空表示不修改）
              CustomTextField(
                labelText: 'ApiKey',
                hintText:
                    controller.isEdit ? '留空表示不修改' : '如：sk-xxx',
                controller: controller.apiKeyController,
                obscureText: true,
                hintTextColor: theme.primaryColor,
              ),
              const SizedBox(height: 16),

              //模型标识
              CustomTextField(
                labelText: '模型标识',
                hintText: '如：gpt-4o-mini',
                controller: controller.modelController,
                hintTextColor: theme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}