import 'package:flutter/material.dart';
import '../../../components/custom_button/index.dart';
import '../../../components/custom_label_value_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class SearchInfoPage extends CustomWidgetNew<SearchInfoLogic> {
  SearchInfoPage({super.key});
  //好友详情页
  @override
  Widget buildWidget(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF9FBFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9FBFF),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
              child: Column(
                    children: [
                      ///上方昵称 头像
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
                            //带边框的头像
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

                            //昵称与账号
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //昵称与特殊效果
                                      Stack(
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.none,
                                        children: [
                                          //特殊效果向下偏移13
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
                                                //隐藏昵称
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

                                      //账号
                                      Text(
                                        controller.friendAccount,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      //性别 生日 年龄
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            //符号
                            Icon(
                                controller.friendSex == "男"
                                    ? Icons.male
                                    : Icons.female,
                                // color: theme.primaryColor,
                                color: controller.friendSex == "男"
                                    ? const Color(0xFF4C9BFF)
                                    : const Color(0xFFFFA0CF),
                                size: 18),
                            const SizedBox(width: 2),
                            //性别
                            Text(
                              controller.friendSex,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                            Container(
                              width: 1,
                              height: 14,
                              color: Colors.black38,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                            //年龄
                            Text(
                              controller.friendBirthday !=''
                              ?DateUtil.calculateAge(controller.friendBirthday)
                              :"未知",
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                            Container(
                              width: 1,
                              height: 14,
                              color: Colors.black38,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                            //生日
                            Text(
                              controller.friendBirthday !=""
                                  ?DateUtil.getYearDayMonth(
                                  controller.friendBirthday)
                                  :"未知",
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 1),

                      //签名
                      CustomLabelValueButton(
                          onTap: () {},
                          width: 50,
                          label: '签名',
                          hint: 'ta没有要说的签名~',
                          maxLines: 10,
                          value: controller.friendSignature),
                      const SizedBox(height: 1),
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
                  text: '加为好友',
                  onTap: controller.goApplyFriend,
                ),
              ),
            ],
          ),
        ),
      );
}
