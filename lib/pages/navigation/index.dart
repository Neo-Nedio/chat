import 'package:flutter/material.dart';

import '../chat_list/index.dart';
import '../contacts/index.dart';
import '../mine/mine.dart';
import '../talk/index.dart';

//主页导航栏
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _selectedIcons = [
    'assets/images/chat.png',
    'assets/images/user.png',
    'assets/images/talk.png',
    'assets/images/mine.png',
  ];

  final List<String> _unselectedIcons = [
    'assets/images/chat-empty.png',
    'assets/images/user-empty.png',
    'assets/images/talk-empty.png',
    'assets/images/mine-empty.png',
  ];

  final List<String> _name = [
    '消息',
    '通讯',
    '说说',
    '我的',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 上半部分：页面内容
      body: PageView(
        controller: _pageController,
        //// 禁止滑动切换
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          ChatListPage(),
          ContactsPage(),
          Talk(),
          Mine(),
        ]
      ),

      // 下半部分：底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,

        selectedItemColor: Theme.of(context).primaryColor,  // 选中文字颜色
        unselectedItemColor: Colors.grey,  // 未选中文字颜色
        showUnselectedLabels: true,  // 显示未选中标签
        backgroundColor: const Color(0xFFEDF2F9),  // 背景色
        type: BottomNavigationBarType.fixed,  // 固定类型（4个以上用fixed，切换时自有颜色变化，shifting有大小变化）

        items: List.generate(_unselectedIcons.length, (index) {
          return BottomNavigationBarItem(
            // 根据选中状态显示不同图标
            icon: Image.asset(
              _currentIndex == index
                  ? _selectedIcons[index]
                  : _unselectedIcons[index],
              width: 26,
              height: 26,
            ),
            label: _name[index],
          );
        }),
      ),
    );
  }
}
