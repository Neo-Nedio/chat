import 'package:flutter/material.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class FriendRequestPage extends CustomWidgetNew<FriendRequestLogic> {
  FriendRequestPage({super.key});

  //申请好友页面
  @override
  Widget buildWidget(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FBFF),
    //标题栏
    appBar: AppBar(
      backgroundColor: const Color(0xFFF9FBFF),
      title: const AppBarTitle('申请信息'),
      centerTitle: true,
    ),

    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        child: Column(
                children: [
                  ///头像 昵称
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient( //渐变
                        colors: [theme.minorColor, const Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        //头像
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: CustomPortrait(
                              url: controller.friendPortrait,
                              size: 70,
                              radius: 35),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //昵称与特殊效果
                                  Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      //向下偏移13的特殊效果
                                      Positioned(
                                        top: 13,
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 0),
                                          child: Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            height: 15,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient( //渐变
                                                colors: [
                                                  theme.primaryColor
                                                      .withValues(alpha: 0.1),
                                                  theme.primaryColor,
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10), // 圆角
                                            ),
                                            //隐藏昵称，用于占位
                                            child: Opacity(
                                              opacity: 0,
                                              child: Text(
                                                controller.friendName,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //真正昵称
                                      Text(
                                        controller.friendName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  //申请输入框
                  CustomTextField(
                    labelText: "填写申请信息",
                    labelTextColor: const Color(0xFF99999a),
                    controller: controller.applyFriendController,
                    inputLimit: 100,
                    onChanged: controller.applyFriendTextChanged,
                    maxLines: 4,
                    suffix: Text('${controller.applyFriendLength}/100'),
                  ),
                ],
              ),
      ),
    ),

    //底部悬浮窗
    bottomNavigationBar: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomButton(
              text: '发送',
              onTap: controller.applyFriend,
            ),
          ),
        ],
      ),
    ),
  );

}
