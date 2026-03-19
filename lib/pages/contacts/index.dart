import 'package:flutter/material.dart';

import '../../api/friend_api.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_search_box/index.dart';


final _friendApi = FriendApi();


//通讯
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<String> tabs = ['我的群聊', '我的好友', '好友通知'];  // 标签页
  int selectedIndex = 1;        // 当前选中的标签索引（默认选中"我的好友"）
  List<dynamic> _friendList = []; // 好友列表数据（按分组）

  @override
  void initState() {
    super.initState();
    // 只在进入页面时拉取一次好友列表，不要放在 build/getContent 里，否则每次重建都会请求
    _onFriendList();
  }

  // 更新好友列表
  void _onFriendList() {
    _friendApi.list().then((res) {
      if (res['code'] == 0) {
        setState(() {
          _friendList = res['data'];
        });
      }
    });
  }

  // 标签切换
  void handlerTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  //页面
  Widget getContent(String tab) {
    switch (tab) {
      case '好友通知':
        return Container(
          color: Colors.red[100],
          child: const Center(child: Text('好友通知内容')),
        );
      case '我的群聊':
        return Container(
          color: const Color(0xFFEDF2F9),
          child: const Center(child: Text('我的群聊内容')),
        );
      case '我的好友':
        return ListView(
          children: [
            // 用...将列表展开
            ..._friendList.map((group) {
//ExpansionTile 是 Flutter 中的可展开/折叠的列表项组件。它包含一个标题行，点击后可以展开显示更多的内容（通常是子列表）
              return ExpansionTile(
                iconColor: const Color(0xFF4C9BFF),  // 箭头图标颜色（蓝色）
                visualDensity: VisualDensity(horizontal: 0, vertical: -4), // 垂直方向更紧凑
                dense: true, // 启用密集模式
                //边框形状
                collapsedShape: RoundedRectangleBorder(  // 收起时的形状
                  borderRadius: BorderRadius.circular(8),
                ),
                shape: RoundedRectangleBorder(  // 展开时的形状
                  borderRadius: BorderRadius.circular(8),
                ),

                //分类名称和人数
                title: Text(
                  '${group['name']}（${group['friends'].length}）',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                //子节点（好友列表）
                children: [
                  ...group['friends'].map(
                    (friend) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: _buildFriendItem(friend),
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      default:
        return Container();
    }
  }

  //好友项
  Widget _buildFriendItem(dynamic friend) {
    return Material(
      borderRadius: BorderRadius.circular(12),  // 圆角12像素
      color: Colors.white,                       // 白色背景
      child: InkWell(
        onTap: () {
          // 添加点击事件
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),  // 上下内边距10
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border(
              bottom: BorderSide( // 底部边框作为分割线
                color: Colors.grey[200]!,
                width: 0.5,
              ),
            ),
          ),

          //主体内容
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),// 左右内边距8
            child: Row(
              children: [
                CustomPortrait(url: friend['portrait']),  // 头像组件

                // 头像和文字的间距
                const SizedBox(width: 12),

                Expanded(                                  // 文字区域填充剩余空间
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            // 姓名
                            friend['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // 备注（如果有）
                          if (friend['remark'] != null &&
                              friend['remark']?.toString().trim() != '')
                            Text(
                              '(${friend['remark']})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────────────────┐
    │  Scaffold (页面骨架)                                          │
    │  ┌─────────────────────────────────────────────────────────┐ │
    │  │  AppBar (顶部导航栏)                                      │ │
    │  │  ┌─────────────────────────────────────────────────────┐ │ │
    │  │  │             通讯列表                          +      │ │ │
    │  │  └─────────────────────────────────────────────────────┘ │ │
    │  ├─────────────────────────────────────────────────────────┤ │
    │  │  Padding (上下5px, 左右16px)                              │ │
    │  │  ┌─────────────────────────────────────────────────────┐ │ │
    │  │  │  Column (垂直布局)                                    │ │ │
    │  │  │  ┌─────────────────────────────────────────────────┐ │ │ │
    │  │  │  │  CustomSearchBox (搜索框)                        │ │ │ │
    │  │  │  │  ┌─────────────────────────────────────────────┐ │ │ │ │
    │  │  │  │  │  🔍 搜索好友或群聊...                        │ │ │ │ │
    │  │  │  │  └─────────────────────────────────────────────┘ │ │ │ │
    │  │  │  └─────────────────────────────────────────────────┘ │ │ │
    │  │  │                                                     │ │ │
    │  │  │  SizedBox(height: 5)                                │ │ │
    │  │  │                                                     │ │ │
    │  │  │  TabBar (标签栏 - 带动画)                            │ │ │
    │  │  │  ┌─────────────────────────────────────────────────┐ │ │ │
    │  │  │  │  Row (水平布局, 两端对齐)                         │ │ │ │
    │  │  │  │  ┌──────────┬──────────┬──────────┐            │ │ │ │
    │  │  │  │  │ Expanded │ Expanded │ Expanded │            │ │ │ │
    │  │  │  │  │ 我的群聊 │ 我的好友 │ 好友通知 │            │ │ │ │
    │  │  │  │  │  (黑色)  │  (蓝色)  │  (黑色)  │            │ │ │ │
    │  │  │  │  │  ─────── │          │          │            │ │ │ │
    │  │  │  │  └──────────┴──────────┴──────────┘            │ │ │ │
    │  │  │  └─────────────────────────────────────────────────┘ │ │ │
    │  │  │                                                     │ │ │
    │  │  │  SizedBox(height: 5)                                │ │ │
    │  │  │                                                     │ │ │
    │  │  │  Expanded (填充剩余空间)                             │ │ │
    │  │  │  ┌─────────────────────────────────────────────────┐ │ │ │
    │  │  │  │  AnimatedSwitcher (内容切换动画)                  │ │ │ │
    │  │  │  │  ┌─────────────────────────────────────────────┐ │ │ │ │
    │  │  │  │  │  getContent(tabs[selectedIndex])             │ │ │ │ │
    │  │  │  │  │  ┌─────────────────────────────────────────┐ │ │ │ │ │
    │  │  │  │  │  │  (根据选中标签显示不同内容)               │ │ │ │ │ │
    │  │  │  │  │  │                                         │ │ │ │ │ │
    │  │  │  │  │  │  [我的好友] 内容:                        │ │ │ │ │ │
    │  │  │  │  │  │  ▼ 家人（2）                            │ │ │ │ │ │
    │  │  │  │  │  │  ┌─────────────────────────────────┐   │ │ │ │ │ │
    │  │  │  │  │  │  │  ●●● 张三 (爸爸)                │   │ │ │ │ │ │
    │  │  │  │  │  │  ├─────────────────────────────────┤   │ │ │ │ │ │
    │  │  │  │  │  │  │  ●●● 李四 (妈妈)                │   │ │ │ │ │ │
    │  │  │  │  │  │  └─────────────────────────────────┘   │ │ │ │ │ │
    │  │  │  │  │  │  ▼ 同事（1）                            │ │ │ │ │ │
    │  │  │  │  │  │  ┌─────────────────────────────────┐   │ │ │ │ │ │
    │  │  │  │  │  │  │  ●●● 王五                       │   │ │ │ │ │ │
    │  │  │  │  │  │  └─────────────────────────────────┘   │ │ │ │ │ │
    │  │  │  │  │  │                                         │ │ │ │ │ │
    │  │  │  │  │  │  [我的群聊] 内容:                       │ │ │ │ │ │
    │  │  │  │  │  │     我的群聊内容                        │ │ │ │ │ │
    │  │  │  │  │  │                                         │ │ │ │ │ │
    │  │  │  │  │  │  [好友通知] 内容:                       │ │ │ │ │ │
    │  │  │  │  │  │     好友通知内容                        │ │ │ │ │ │
    │  │  │  │  │  └─────────────────────────────────────────┘ │ │ │ │ │
    │  │  │  │  └─────────────────────────────────────────────┘ │ │ │ │
    │  │  │  └─────────────────────────────────────────────────┘ │ │ │
    │  │  └─────────────────────────────────────────────────────┘ │ │
    │  └─────────────────────────────────────────────────────────┘ │
    └─────────────────────────────────────────────────────────────┘
    */
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),// 浅蓝色背景
      appBar: AppBar(
        centerTitle: true,
        title: const Text('通讯列表'),
        backgroundColor: const Color(0xFFF9FBFF),// 浅蓝色背景
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.add, size: 32),     // 加号图标
            offset: const Offset(0, 50),                // 向下偏移50像素
            shape: RoundedRectangleBorder(               // 圆角形状
              borderRadius: BorderRadius.circular(5),
            ),
            color: const Color(0xFFFFFFFF),              // 白色背景

            // 菜单项1: 扫一扫
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 1,
                height: 40,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconData(0xe61e, fontFamily: 'IconFont'), size: 20),
                    SizedBox(width: 12),
                    Text('扫一扫', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              //分割线
              _buildPopupDivider(),

              // 菜单项2: 添加好友
              PopupMenuItem(
                value: 1,
                height: 40,
                child: const Row(
                  children: [
                    Icon(Icons.person_add, size: 20),
                    SizedBox(width: 12),
                    Text('添加好友', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              // 分割线
              _buildPopupDivider(),

              // 菜单项3: 创建群聊
              PopupMenuItem(
                value: 2,
                height: 40,
                child: const Row(
                  children: [
                    Icon(Icons.group_add, size: 20),
                    SizedBox(width: 12),
                    Text('创建群聊', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),

      //主体内容
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Column(
          children: [
            // 搜索框
            CustomSearchBox(
              isCentered: false,
              onChanged: (value) {},
            ),

            const SizedBox(height: 5),

            //分类
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
              children: List.generate(tabs.length, (index) {
                return Expanded( // 每个标签平均分配宽度
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),  // 动画时长300ms
                    alignment: Alignment.center,                  // 居中对齐
                    child: GestureDetector(
                      onTap: () => handlerTabTapped(index), // 点击时调用切换方法
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),  // 动画时长
                        curve: Curves.easeInOut,                      // 动画曲线：缓入缓出
                        padding: const EdgeInsets.all(5),              // 内边距5px
                        margin: EdgeInsets.symmetric(
                          horizontal: index == selectedIndex ? 4.0 : 0.0,  // 选中时增加水平外边距
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),      // 圆角1px
                          color: Colors.transparent,                    // 透明背景
                          border: Border(
                            bottom: BorderSide(                         // 底部边框（下划线）
                              color: index == selectedIndex
                                  ? const Color(0xE64C9BFF)            // 选中时蓝色
                                  : Colors.transparent,                  // 未选中时透明
                              width: 2,                                  // 边框宽度2px
                            ),
                          ),
                        ),

                        //确保文字在容器内居中显示
                        child: Center(
                          //文字样式动画的组件
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: index == selectedIndex
                                  ? const Color(0xE64C9BFF)  // 选中时蓝色
                                  : Colors.black,              // 未选中时黑色
                              fontSize: 16,                    // 字号16px
                            ),
                            child: Text(tabs[index]),          // 实际文字内容
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            //分割
            const SizedBox(height: 5),

            //主体内容
            Expanded(
              //内容切换动画的组件
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: getContent(tabs[selectedIndex]),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
