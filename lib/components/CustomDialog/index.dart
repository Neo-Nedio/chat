import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../custom_button/index.dart';

//自定义确认对话框组件，用于显示带有"确定"和"取消"按钮的提示弹窗。
class CustomDialog {
  static void showTipDialog(
      BuildContext context,
      {
        required String text,           // 提示内容
        required VoidCallback onOk,     // 确定按钮回调
        required VoidCallback onCancel  // 取消按钮回调
      }
)
  {
    //获取主题
    GlobalThemeConfig theme = Get.find<GlobalThemeConfig>();

    //弹窗对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击外部关闭弹窗
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), //// 圆角 10px
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //标题
                Text(
                  '提示',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),

                const SizedBox(height: 20),

                //提示内容
                Text(text, textAlign: TextAlign.center),

                const SizedBox(height: 20),

                //按钮行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //确定按钮
                    Expanded(
                      child: CustomButton(
                        text: '确定',
                        onTap: () {
                          onOk();
                          Navigator.of(context).pop();
                        },
                        width: 120,
                        height: 34,
                      ),
                    ),
                    const SizedBox(width: 10),
                    //取消按钮
                    Expanded(
                      child: CustomButton(
                        text: '取消',
                        onTap: () {
                          onCancel();
                          Navigator.of(context).pop();
                        },
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
}
