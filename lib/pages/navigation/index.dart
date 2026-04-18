import 'package:chat_mobile/pages/mine/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/custom_tip/index.dart';
import '../../utils/getx_config/config.dart';
import '../chat_list/index.dart';
import '../contacts/index.dart';
import '../talk/index.dart';
import 'logic.dart';

//主页导航栏
class NavigationPage extends CustomWidget<NavigationLogic> {
  NavigationPage({required super.key});

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return ChatListPage(key: const Key('chat_list'));
      case 1:
        return ContactsPage(key: const Key('contacts'));
      case 2:
        return TalkPage(key: const Key('talk'));
      case 3:
        return MinePage(key: const Key('mine'));
      default:
        return ChatListPage(key: const Key('chat_list'));
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Obx(
        ()=>Scaffold(
          // 上半部分：页面内容
          body: _buildPage((controller.currentIndex.value)),

          // 下半部分：底部导航栏
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: (index) => controller.currentIndex.value = index,

            selectedItemColor: theme.primaryColor,  // 选中文字颜色
            unselectedItemColor: Colors.grey,  // 未选中文字颜色
            showUnselectedLabels: true,  // 显示未选中标签
            backgroundColor: const Color(0xFFEDF2F9),  // 背景色
            type: BottomNavigationBarType.fixed,  // 固定类型（4个以上用fixed，切换时自有颜色变化，shifting有大小变化）

            items: List.generate(controller.unselectedIcons.length, (index) {
              return BottomNavigationBarItem(
                // 根据选中状态显示不同图标
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      controller.currentIndex.value == index
                          ? 'assets/images/${controller.selectedIcons[index]}-${theme.themeMode}.png'
                          : controller.unselectedIcons[index],
                      width: 26,
                      height: 26,
                    ),
                    //未读消息
                    if (controller.selectedIcons[index] == 'chat' &&
                        globalData.getUnreadCount('chat') > 0)
                      CustomTip(globalData.getUnreadCount('chat')),
                    if (controller.selectedIcons[index] == 'user' &&
                        (globalData.getUnreadCount('friendNotify') +
                                globalData.getUnreadCount('groupNotify')) >
                            0)
                      CustomTip(globalData.getUnreadCount('friendNotify') +
                          globalData.getUnreadCount('groupNotify')),
                  ],
                ),
                label: controller.name[index],
              );
            }),
          ),
        ),
    );
  }
}
