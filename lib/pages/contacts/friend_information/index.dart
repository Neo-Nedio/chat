import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_button/index.dart';
import '../../../components/custom_image_group/index.dart';
import '../../../components/custom_label_value_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../utils/String.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class FriendInformationPage extends CustomWidget<FriendInformationLogic> {
  FriendInformationPage({super.key});

  //分割线
  PopupMenuEntry<int> _buildPopupDivider() {
    return PopupMenuItem<int>(
      enabled: false,
      height: 1,
      child: Container(
        height: 1,
        padding: const EdgeInsets.all(0),
        color: Colors.grey[200],
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) => GestureDetector(
    child: Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      //标题
      appBar: AppBar(
          centerTitle: true,
          title: const AppBarTitle('好友资料'),
          backgroundColor: const Color(0xFFF9FBFF),
          actions: [
            // 关注/取消关注按钮
            IconButton(
              onPressed: controller.setConcern,
              icon: controller.isConcern
                  ? Icon(
                Icons.favorite,
                size: 32,
                color: theme.primaryColor,
              )
                  : const Icon(
                Icons.favorite_border,
                size: 32,
                color: Color(0xFF989898),
              ),
            ),
            // 更多菜单按钮
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 32),
              offset: const Offset(0, 50), //向下偏移，防止子菜单遮挡
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: const Color(0xFFFFFFFF),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                //// 删除好友
                PopupMenuItem(
                  value: 1,
                  height: 40,
                  onTap: controller.deleteFriend,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, size: 20),
                      SizedBox(width: 12),
                      Text('删除好友', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                _buildPopupDivider(), // 分割线
                // 特别关心
                PopupMenuItem(
                  value: 1,
                  height: 40,
                  onTap: controller.setConcern,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 20),
                      const SizedBox(width: 12),
                      Text(controller.isConcern ? '取消特别关心' : '特别关心',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ]),

      //主体内容
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,//水平居中
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //竖直两端
              children: [
                    //头部信息卡片
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient( // 渐变背景
                          colors: [
                            theme.minorColor,
                            const Color(0xFFFFFFFF)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // 头像（带白色边框）
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,//白色边框
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

                          //// 昵称和账号
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        //特效
                                        Positioned(
                                          top: 13,//向下偏移
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 0,
                                                vertical: 0),
                                            child: Container(
                                              padding: const EdgeInsets
                                                  .symmetric(horizontal: 5),
                                              height: 15,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(//渐变
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
                                              child: Opacity( //隐形文字占位
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
                                        //真正显示的名字
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

                    //性别/年龄/生日行
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          //左侧图标
                          Icon(
                              controller.friendGender == "男"
                                  ? Icons.male
                                  : Icons.female,
                              color: controller.friendGender == "男"
                                  ? const Color(0xFF4C9BFF)
                                  : const Color(0xFFFFA0CF),
                              size: 18),
                          //左右间隔
                          const SizedBox(width: 2),
                          //性别
                          Text(
                            controller.friendGender,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                          ),
                          //左右分割线
                          Container(
                            width: 1,
                            height: 14,
                            color: Colors.black38,
                            margin:
                            const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          //生日
                          Text(
                            controller.friendBirthday != ""
                            ?DateUtil.calculateAge(
                                controller.friendBirthday)
                            : "未知",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                          ),
                          //左右分割线
                          Container(
                            width: 1,
                            height: 14,
                            color: Colors.black38,
                            margin:
                            const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          //年龄
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

                    //备注(会根据是否有备注在value和hint之间切换)
                    CustomLabelValueButton(
                        onTap: () => Get.toNamed('set_remark', arguments: {
                          'remark': controller.friendRemark,
                          'friendId': controller.friendId
                        }),
                        width: 50,
                        label: '备注',
                        hint: '未设置备注',
                        value: controller.friendRemark),

                    const SizedBox(height: 1),

                    //分组
                    CustomLabelValueButton(
                        onTap: () => Get.toNamed('set_group', arguments: {
                          'groupName': controller.friendGroup,
                          'friendId': controller.friendId
                        }),
                        width: 50,
                        label: '分组',
                        value: controller.friendGroup),

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

                    //说说
                    CustomLabelValueButton(
                      onTap: () => Get.toNamed('/talk', arguments: {
                        'userId': controller.friendId,
                        'title': StringUtil.isNotNullOrEmpty(
                            controller.friendRemark)
                            ? controller.friendRemark
                            : controller.friendName,
                      }),
                      width: 50,
                      label: '说说',
                      hint: '这个人很懒，什么都没留下~',
                      child: (controller.talkContent['text']?.isNotEmpty ==
                          true ||
                          (controller.talkContent['img']?.isNotEmpty ??
                              false))
                      //文字或者图片存在时显示
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller
                              .talkContent['text']?.isNotEmpty ==
                              true)
                            Text(
                              controller.talkContent['text'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          if (controller
                              .talkContent['img']?.isNotEmpty ==
                              true)
                            CustomImageGroup(
                              imagesList:
                              controller.talkContent['img'],
                              userId: controller.friendId,
                            ),
                        ],
                      )
                          : null,
                    ),
              ],
            ),
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
                text: '发消息',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                text: '视频聊天',
                onTap: () {},
                type: 'minor',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
