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

  //构建单个真实 Tab（tabIndex 为 0~3，对应 currentIndex 体系）
  BottomNavigationBarItem _buildNavItem(int tabIndex) {
    return BottomNavigationBarItem(
      // 根据选中状态显示不同图标
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            controller.currentIndex.value == tabIndex
                ? 'assets/images/${controller.selectedIcons[tabIndex]}-${theme.themeMode}.png'
                : controller.unselectedIcons[tabIndex],
            width: 26,
            height: 26,
          ),
          //未读消息
          if (controller.selectedIcons[tabIndex] == 'chat' &&
              globalData.getUnreadCount('chat') > 0)
            CustomTip(globalData.getUnreadCount('chat')),
          if (controller.selectedIcons[tabIndex] == 'user' &&
              (globalData.getUnreadCount('friendNotify') +
                      globalData.getUnreadCount('groupNotify')) >
                  0)
            CustomTip(globalData.getUnreadCount('friendNotify') +
                globalData.getUnreadCount('groupNotify')),
        ],
      ),
      label: controller.name[tabIndex],
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Obx(
        ()=>Scaffold(
          // 上半部分：页面内容
          body: _buildPage((controller.currentIndex.value)),

          // 下半部分：底部导航栏（中间凹槽 + 圆形 AI 按钮）
          bottomNavigationBar: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              BottomNavigationBar(
                //中间插入凹槽占位后，选中下标需要错位换算
                currentIndex: controller.currentIndex.value >= 2
                    ? controller.currentIndex.value + 1
                    : controller.currentIndex.value,
                onTap: (index) {
                  if (index == 2) return; //中间凹槽占位，不可点击
                  controller.currentIndex.value = index > 2 ? index - 1 : index;
                },

                selectedItemColor: theme.primaryColor,  // 选中文字颜色
                unselectedItemColor: Colors.grey,  // 未选中文字颜色
                showUnselectedLabels: true,  // 显示未选中标签
                backgroundColor: const Color(0xFFEDF2F9),  // 背景色
                type: BottomNavigationBarType.fixed,  // 固定类型（4个以上用fixed，切换时自有颜色变化，shifting有大小变化）

                items: [
                  _buildNavItem(0),
                  _buildNavItem(1),
                  //中间凹槽占位：撑起缺口，不显示内容
                  const BottomNavigationBarItem(
                    icon: SizedBox(width: 48, height: 26),
                    label: '',
                  ),
                  _buildNavItem(2),
                  _buildNavItem(3),
                ],
              ),

              //圆形 直播间 按钮，悬浮在凹槽中间并向上凸出
              Positioned(
                top: -22,
                child: GestureDetector(
                  onTap: () => Get.toNamed('/live'),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor,
                      //与导航栏同色的描边，视觉上形成凹槽
                      border: Border.all(
                        color: const Color(0xFFEDF2F9),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.live_tv_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
