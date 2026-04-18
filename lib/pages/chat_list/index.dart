import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_badge/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_search_box/index.dart';
import '../../utils/String.dart';
import '../../utils/date.dart';
import '../../utils/getx_config/config.dart';
import '../../utils/msg.dart';
import 'logic.dart';


//聊天主页面

class ChatListPage extends CustomWidget<ChatListLogic> {
  ChatListPage({super.key});


  @override
  init(BuildContext context) {
    controller.onGetChatList();
  }


  @override
  Widget buildWidget(BuildContext context) {

/*
┌─────────────────────────────────────────────────┐
│  AppBar 顶部导航栏                                │
│  ┌─────────────────────────────────────────────┐ │
│  │             聊天列表                    +   │ │
│  └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│  Padding (上下5px, 左右16px)                      │
│  ┌─────────────────────────────────────────────┐ │
│  │  Column 垂直布局                             │ │
│  │  ┌───────────────────────────────────────┐ │ │
│  │  │  CustomSearchBox 搜索框                │ │ │
│  │  │  ┌───────────────────────────────────┐ │ │ │
│  │  │  │  🔍 搜索...                        │ │ │ │
│  │  │  └───────────────────────────────────┘ │ │ │
│  │  └───────────────────────────────────────┘ │ │
│  │                                             │ │
│  │  Expanded (填充剩余空间)                     │ │
│  │  ┌───────────────────────────────────────┐ │ │
│  │  │  RefreshIndicator 下拉刷新             │ │ │
│  │  │  ┌───────────────────────────────────┐ │ │ │
│  │  │  │  ListView 可滚动列表               │ │ │ │
│  │  │  │  ┌───────────────────────────────┐ │ │ │ │
│  │  │  │  │                               │ │ │ │ │
│  │  │  │  │  ═════ 搜索结果 ═════         │ │ │ │ │
│  │  │  │  │  ┌─────────────────────────┐  │ │ │ │ │
│  │  │  │  │  │  👤 张三 (好友)          │  │ │ │ │ │
│  │  │  │  │  └─────────────────────────┘  │ │ │ │ │
│  │  │  │  │  ┌─────────────────────────┐  │ │ │ │ │
│  │  │  │  │  │  👤 李四 (同事)          │  │ │ │ │ │
│  │  │  │  │  └─────────────────────────┘  │ │ │ │ │
│  │  │  │  │                               │ │ │ │ │
│  │  │  │  │  ═════ 置顶 ═══════           │ │ │ │ │
│  │  │  │  │  ┌─────────────────────────┐  │ │ │ │ │
│  │  │  │  │  │  📌 👤 产品群    15:30   │  │ │ │ │ │
│  │  │  │  │  │     3条新消息      󰀃 3   │  │ │ │ │ │
│  │  │  │  │  └─────────────────────────┘  │ │ │ │ │
│  │  │  │  │  ┌─────────────────────────┐  │ │ │ │ │
│  │  │  │  │  │  📌 👤 技术群    14:20   │  │ │ │ │ │
│  │  │  │  │  │     代码已合并           │  │ │ │ │ │
│  │  │  │  │  └─────────────────────────┘  │ │ │ │ │
│  │  │  │  │                               │ │ │ │ │
│  │  │  │  │  ═════ 全部 ═══════           │ │ │ │ │
│  │  │  │  │  ┌─────────────────────────┐  │ │ │ │ │
│  │  │  │  │  │  👤 测试群    13:45      │  │ │ │ │ │
│  │  │  │  │  │     测试通过             │  │ │ │ │ │
│  │  │  │  │  └─────────────────────────┘  │ │ │ │ │
│  │  │  │  │  ┌─────────────────────────┐  │ │ │ │ │
│  │  │  │  │  │  👤 设计群    12:10      │  │ │ │ │ │
│  │  │  │  │  │     设计稿已更新   󰀃 2   │  │ │ │ │ │
│  │  │  │  │  └─────────────────────────┘  │ │ │ │ │
│  │  │  │  └───────────────────────────────┘ │ │ │ │
│  │  │  └───────────────────────────────────┘ │ │ │
│  │  └───────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘

    点击加号后：
┌─────────────────────────────────────┐
│  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  +   │
│          聊天列表          ↑          │
│                         偏移50       │
│                        ┌─────────┐   │
│                        │ 🔍 扫一扫│   │
│                        ├─────────┤   │
│                        │ 👤 添加好友│   │
│                        ├─────────┤   │
│                        │ 👥 创建群聊│   │
│                        └─────────┘   │
└─────────────────────────────────────┘

    图例：
    ●●● = 头像（圆形）
    󰀃 = 红色未读红点
    + = 添加按钮
    🔍 = 搜索图标*/
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true, //  // 标题居中显示
        title: const AppBarTitle('聊天列表'),
        backgroundColor: const Color(0xFFF9FBFF),
        // 应用栏右侧的操作按钮
        actions: [
                PopupMenuButton(
              icon: const Icon(Icons.add, size: 32),  // 按钮图标：加号，大小32
              offset: const Offset(0, 50),            // 菜单偏移量：x=0, y=50（向下偏移50）
              shape: RoundedRectangleBorder(           // 菜单形状
                borderRadius: BorderRadius.circular(5), // 圆角5像素
              ),
              color: const Color(0xFFFFFFFF),          // 菜单背景色：白色
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                //扫一扫
                PopupMenuItem(
                  value: 1,           // 选中时的返回值
                  height: 40,         // 菜单项高度40像素
                  onTap: () => Get.toNamed('/qr_code_scan'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,  // Row宽度自适应内容
                    children: [
                      Icon(IconData(0xe61e, fontFamily: 'IconFont'), size: 20), // 自定义图标
                      SizedBox(width: 12),  // 图标和文字间距12
                      Text('扫一扫', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),

                //分割线
                _buildPopupDivider(),

                //添加好友
                PopupMenuItem(
                  value: 1,           // 选中时的返回值
                  height: 40,         // 菜单项高度40像素
                  onTap: ()=> Get.toNamed('/add_friend'),      // 点击回调
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add, size: 20),
                      SizedBox(width: 12),
                      Text('添加好友', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),

                //分割线
                _buildPopupDivider(),

                //添加群聊
                PopupMenuItem(
                  value: 3,
                  height: 40,
                  onTap: () => Get.toNamed('/add_group'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups, size: 20),
                      SizedBox(width: 12),
                      Text('添加群聊', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),

                //分割线
                _buildPopupDivider(),

                //创建群聊
                PopupMenuItem(
                  value: 2,
                  height: 40,
                  onTap: () => Get.toNamed('/create_chat_group'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_add, size: 20),
                      SizedBox(width: 12),
                      Text('创建群聊', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),

      //主体内容：聊天列表
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Column(
          children: [
            //搜索框组件
            CustomSearchBox(
              isCentered: false,
              onChanged: (value) {
                //更新搜索内容
                controller.onSearchFriend(value);
              },
            ),
            if(controller.searchList.isNotEmpty ||
                controller.otherList.isNotEmpty ||
                controller.topList.isNotEmpty)
            // Expanded让ListView填充剩余空间
              Expanded(
                //下拉刷新组件
                  child: RefreshIndicator(
                    onRefresh: () async {  // 下拉刷新时触发的回调函数
                      controller.onGetChatList();    // 调用API重新获取聊天列表
                      return Future.delayed(const Duration(milliseconds: 700)); // 延迟700ms返回
                    },
                    color: theme.primaryColor,

                    child: ListView(
                      children: [

                        if (controller.searchList.isNotEmpty) ...[
                           Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "搜索结果",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          //List 不能直接作为 child,所以要加上...展开成多个 Widget
                          ...controller.searchList.map((friend) =>
                              _buildSearchItem(friend, friend['friendId'])),
                        ],

                        if (controller.topList.isNotEmpty) ...[
                           Padding(
                            // 显示"置顶"标题
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "置顶",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          // 遍历topList，为每个chat创建列表项
                          // 使用展开操作符...将生成的组件列表展开
                          ...controller.topList
                              .map((chat) => _buildChatItem(chat, chat['id'])),
                        ],

                        if (controller.otherList.isNotEmpty) ...[
                          Padding(
                            // "未置顶"标题
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "未置顶",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          ...controller.otherList
                              .map((chat) => _buildChatItem(chat, chat['id'])),
                        ],
                      ],
                    ),
                  )
              ),

            if (controller.searchList.isEmpty &&
                controller.otherList.isEmpty &&
                controller.topList.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/empty-bg.png',
                        width: 100,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '暂无聊天记录~',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

/*  正常状态（未滑动）：
 ┌─────────────────────────────────────────────────┐
│  开始滑动：                                       │
│  ┌─────────────────────────────────────────┐     │
│  │  ●●●  张三                      14:30  │  ▶  │
│  └─────────────────────────────────────────┘     │
│                                                   │
│  滑动中：                                         │
│  ┌───────────────────────────────────────┐  ┌─── │
│  │  ●●●  张三                      14:30│  │置  │
│  └───────────────────────────────────────┘  └─── │
│                                                   │
│  滑动完成：                                       │
│  ┌─────────────────────────────────────┐  ┌────┬────┐
│  │  ●●●  张三                      14:30│  │置顶│删除│
│  └─────────────────────────────────────┘  └────┴────┘
└─────────────────────────────────────────────────┘*/

  //构建可滑动的聊天项
  Widget _buildChatItem(dynamic chat, String id) {
    // 返回Slidable组件（可左右滑动的组件）
    return Slidable(
      key: ValueKey(id),
      // 结束滑动的操作面板（右滑菜单）
      endActionPane: ActionPane(
        motion: const ScrollMotion(),  // 滑动动画效果
        // extentRatio: chat.isTop ? 0.625 : 0.5,
        children: [
          // 第一个滑动按钮
          SlidableAction(
            padding: const EdgeInsets.all(0),  // 内边距为0
            onPressed: (context) => controller.onTopStatus(id, chat['isTop']),  // 点击调用置顶切换
            backgroundColor: theme.primaryColor, //跟随主题
            foregroundColor: Colors.white,        // 白色图标和文字
            // 根据置顶状态显示不同的图标：置顶显示图钉，不置顶显示空心图钉
            icon: chat['isTop'] ? Icons.push_pin_outlined : Icons.push_pin,
            // 根据置顶状态显示不同的文字
            label: chat['isTop'] ? '取消置顶' : '置顶',
          ),
          // 第二个滑动按钮（删除）
          SlidableAction(
            padding: const EdgeInsets.all(0),
            onPressed: (context) => controller.onDeleteChatList(id),  // 点击调用删除
            backgroundColor: const Color(0xFFFF4C4C),    // 红色背景
            foregroundColor: Colors.white,                // 白色图标和文字
            icon: Icons.delete,  // 垃圾桶图标
            label: '删除',        // 文字标签
          ),
        ],
      ),

      // 列表项的主要内容
      child: Material(
        color: Colors.white,      // 白色背景
        borderRadius: BorderRadius.circular(12.0),  // 圆角12
        // InkWell 必须放在 Material 内才能工作
        child: InkWell( //点击波纹
          onTap: () async {
            await Get.toNamed('/chat_frame', arguments: {
              'chatInfo': chat,
            });
            controller.onGetChatList();
          },
          borderRadius: BorderRadius.circular(12),  // 和Material一致的圆角
          child:  Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),  // 上下内边距10
          decoration: BoxDecoration(  // 容器装饰
            borderRadius: BorderRadius.circular(12.0),  // 圆角12
            border: Border(
              // 底部边框
              bottom: BorderSide(
                color: Colors.grey[100]!,  // 浅灰色
                width: 1,                // 边框宽度0.5
              ),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row( // 水平排列
              children: [
                // 圆角头像
                CustomPortrait(portrait: chat['portrait'] ?? ''),

                // 间距12
                const SizedBox(width: 12),

                // Expanded让这个组件填充剩余空间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
                    children: [
                      // 第一行：用户名和时间
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                        children: [
                          Row(
                            children: [
                              Text(  // 用户名
                                StringUtil.isNotNullOrEmpty(chat['remark'])
                                    ? chat['remark']
                                    : chat['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,  // 中等粗细
                                ),
                              ),
                              const SizedBox(width: 5),
                              //如果是群聊，添加徽章组件
                              if (chat['type'] == 'group')
                                const CustomBadge(text: '群'),
                            ],
                          ),
                          Text(  // 最后消息时间
                            DateUtil.formatTime(chat['updateTime']),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],  // 灰色文字
                            ),
                          ),
                        ],
                      ),

                      // 间距4
                      const SizedBox(height: 4),

                      // 第二行：最后消息和未读数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                        children: [
//Expanded确保了消息文本和未读红点始终在同一行，且红点固定在右侧，消息文本自适应剩余宽度，不会破坏布局。
                          Expanded(  // 消息文本填充剩余空间
                            child: Text(
                              MsgUtil.getMsgContent(
                                  chat['lastMsgContent']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],  // 灰色文字
                              ),
                              maxLines: 1,                 // 最多显示1行
                              overflow: TextOverflow.ellipsis,  // 超出显示省略号
                            ),
                          ),
                          // 如果有未读消息
                          if ((chat['unreadNum'] ?? 0) > 0)
                            Container(
                              width: 16,
                              height: 16,
                              padding: const EdgeInsets.all(0),  // 内边距0
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF4C4C),  // 红色背景
                                shape: BoxShape.circle,      // 圆形
                              ),
                              child: Center(//居中显示
                                child: Text(  // 显示未读数量
                                  chat['unreadNum'] < 99
                                      ? chat['unreadNum'].toString()
                                      : '99',
                                  style: const TextStyle(
                                    color: Colors.white,  // 白色文字
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          ),
        ),
      ),
    );
  }

  //弹出菜单分割线
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

 /*
  ┌─────────────────────────────────────────────────┐
  │  Material (圆角12, 白色背景)                      │
  │  ┌─────────────────────────────────────────────┐ │
  │  │  InkWell (点击波纹效果)                       │ │
  │  │  ┌─────────────────────────────────────────┐ │ │
  │  │  │  Container (上下内边距10)                │ │ │
  │  │  │  ┌─────────────────────────────────────┐ │ │ │
  │  │  │  │  Padding (左右内边距8)               │ │ │ │
  │  │  │  │  ┌─────────────────────────────────┐ │ │ │ │
  │  │  │  │  │  Row                            │ │ │ │ │
  │  │  │  │  │  ┌───────────┐    ┌──────────┐ │ │ │ │ │
  │  │  │  │  │  │           │    │          │ │ │ │ │ │
  │  │  │  │  │  │   头像    │    │  姓名    │ │ │ │ │ │
  │  │  │  │  │  │  50x50    │    │  备注    │ │ │ │ │ │
  │  │  │  │  │  │  圆形     │    │          │ │ │ │ │ │
  │  │  │  │  │  │           │    │          │ │ │ │ │ │
  │  │  │  │  │  └───────────┘    └──────────┘ │ │ │ │ │
  │  │  │  │  │  ←──间距12──→                    │ │ │ │ │
  │  │  │  │  └─────────────────────────────────┘ │ │ │ │
  │  │  │  └─────────────────────────────────────┘ │ │ │
  │  │  └─────────────────────────────────────────┘ │ │
  │  └─────────────────────────────────────────────┘ │
  └─────────────────────────────────────────────────┘
*/
  Widget _buildSearchItem(dynamic friend, String id) {
    return Material(
      borderRadius: BorderRadius.circular(12),// 圆角12
      color: Colors.white,                       // 白色背景
      // InkWell 必须放在 Material 内才能工作
      child: InkWell(
        onTap: () async {
          await Get.toNamed('/chat_frame', arguments: {
            'chatInfo': friend,
          });
          controller.onGetChatList();
        },
        borderRadius: BorderRadius.circular(12),  // 和Material一致的圆角

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),  // 上下内边距10
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), //// 圆角12
            border: Border(
              bottom: BorderSide( // 底部边框作为分割线
                color: Colors.grey[200]!,
                width: 0.5,
              ),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),  // 左右内边距8
            child: Row(
              children: [
                //圆角头像
                CustomPortrait(portrait: friend['portrait']),

                //分割线
                const SizedBox(width: 12),

                Expanded(  // 填充剩余所有空间
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
                    children: [
                      Row(  // 姓名和备注放在同一行
                        children: [
                          // 姓名
                          Text(
                            friend['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          // 如果有备注，显示在括号里
                          if (friend['remark']!=null && friend['remark']?.toString().trim() != '')
                            Text(
                              '(${friend['remark']})',  // 格式： (备注)
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
}
