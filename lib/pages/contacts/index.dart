import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_search_box/index.dart';
import '../../components/custom_text_button/index.dart';
import '../../components/custom_tip/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';



//通讯页面
class ContactsPage extends CustomWidget<ContactsLogic> {
  ContactsPage({super.key});

  @override
  init(BuildContext context) {
    controller.init();
  }

  //页面
  Widget getContent(String tab) {
    switch (tab) {
      case '通知':
        return RefreshIndicator(
          onRefresh: () async {
            controller.onNotifyFriendList();
            return Future.delayed(const Duration(milliseconds: 700));
          },
          child: ListView(
            children: [
              // 用...将列表展开
              ...controller.notifyFriendList.map((notify) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildNotifyFriendItem(notify),
              )),
            ],
          ),
        );
      case '我的群聊':
        return RefreshIndicator(
          onRefresh: () async {
            controller.onChatGroupList();
            return Future.delayed(const Duration(milliseconds: 700));
          },
          child: ListView(
            children: [
              ...controller.chatGroupList.map(
                    (group) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: _buildChatGroupItem(group),
                ),
              ),
            ],
          ),
        );
      case '我的好友':
        return RefreshIndicator(
            onRefresh: () async {
              controller.onFriendList();
              return Future.delayed(const Duration(milliseconds: 700));
            },
            child: ListView(
              children: [
                // 用...将列表展开
                ...controller.friendList.map((group) {
                  return GestureDetector(
                    onLongPress: controller.onLongPressGroup, //对列表长按时，进入分组设置页面
                    //ExpansionTile 是 Flutter 中的可展开/折叠的列表项组件。它包含一个标题行，点击后可以展开显示更多的内容（通常是子列表）
                    child:  ExpansionTile(
                      iconColor:  theme.primaryColor, // 箭头图标颜色
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
                    ),
                  );
                }),
              ],
            )
        );
      default:
        return Container();
    }
  }

  //底部弹出
  void _showDeleteGroupBottomSheet(dynamic friend) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomTextButton(friend['isConcern'] ? '取消特别关心' : '设置特别关心',
                  onTap: () => controller.onSetConcernFriend(friend),
                  textColor: theme.primaryColor,
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  //好友项
  Widget _buildFriendItem(dynamic friend) {
    return Material(
      borderRadius: BorderRadius.circular(12),  // 圆角12像素
      color: Colors.white,                       // 白色背景
      child: InkWell(
        onTap: () => controller.handlerFriendTapped(friend), //点击进入详情页
        onLongPress: () => _showDeleteGroupBottomSheet(friend), //长按可设置/取消特别关心
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
                CustomPortrait(portrait: friend['portrait']),  // 头像组件

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

  /// 好友申请附言：后端可能给 String 或其它类型，统一成可展示的字符串
  String _notifyApplyContent(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    return raw.toString();
  }

  //好友通知项
  Widget _buildNotifyFriendItem(dynamic notify) {
    //判断通知方向
    bool isFromCurrentUser = controller.currentUserId == notify['fromId'];

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: controller.onReadNotify, //消息已读
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 0.5,
              ),
            ),
          ),

          //好友通知
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                //头像（接口可能 null，避免传入非 String 导致构建崩溃）
                CustomPortrait(
                    portrait: (isFromCurrentUser
                            ? notify['toPortrait'] // 我发起的 → 显示对方头像
                            : notify['fromPortrait']) // 别人发来的 → 显示对方头像
                        ?.toString() ??
                        ''),

                //间隔
                const SizedBox(width: 12),

                //文字区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //用户名
                      Row(
                        children: [
                          Text(
                            (isFromCurrentUser
                                    ? notify['toName'] // 我发起的 → 显示对方名字
                                    : notify['fromName']) // 别人发来的 → 显示对方名字
                                ?.toString() ??
                                '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          //时间
                          // const SizedBox(width: 2),
                          // Text(
                          //   DateUtil.formatTime(notify['createTime']),
                          //   style: TextStyle(
                          //       fontSize: 12, color: Colors.grey[600]),
                          // )
                        ],
                      ),

                      //上下间隔
                      const SizedBox(height: 2),

                      //状态提示行
                      Text(
                        _getNotifyContentTip(
                            notify['status'], isFromCurrentUser),
                        style: TextStyle(
                            fontSize: 12, color: theme.primaryColor),
                      ),

                      //上下间隔
                      const SizedBox(height: 2),


                      //申请内容行
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                        children: [
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,  // 超出显示省略号
                              maxLines: 1,                       // 最多1行
                              _notifyApplyContent(notify['content']),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                //左右间隔
                const SizedBox(width: 20),

                //操作区域
                _getNotifyOperateTip(notify['status'], isFromCurrentUser,notify),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //获得状态提示
  String _getNotifyContentTip(status, isFromCurrentUser) {
    // 别人发来的请求（我是接收方）
    if (!isFromCurrentUser) return "请求加你为好友";

    switch (status) {
      case "wait":
        {
          return "正在验证请求";
        }
      case "reject":
        {
          return "已拒绝申请请求";
        }
      case "agree":
        {
          return "已同意申请请求";
        }
    }
    return "";
  }

  //获得操作提示
  Widget _getNotifyOperateTip(status, isFromCurrentUser,[dynamic notify]) {
    // 情况1：别人发来的待处理请求 → 显示操作按钮
    if (!isFromCurrentUser && status == "wait") {
      return Row(
        children: [
          CustomTextButton(
            "同意",
            onTap: () => controller.handlerAgreeFriend(notify),
          ),

          const SizedBox(width: 10),

          CustomTextButton(
            "拒绝",
            onTap: () => controller.handlerRejectFriend(notify),
            textColor: Colors.grey[600],
          ),
          const SizedBox(width: 5), // 右边距
        ],
      );
    }

    // 情况2：我方请求 → 显示状态文字
    switch (status) {
      case "wait":
        {
          return Text(
            "等待验证",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          );
        }
      case "reject":
        {
          return Text(
            "已拒绝",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          );
        }
      case "agree":
        {
          return Text(
            "已同意",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          );
        }
    }
    return const Text("");
  }

  Widget _buildChatGroupItem(dynamic group) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          controller.onToSendGroupMsg(group['id']);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 0.5,
              ),
            ),
          ),

          //主体内容
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [

                //群头像
                CustomPortrait(portrait: group['portrait']),

                //固定间距
                const SizedBox(width: 12),

                //文字区域（填充剩余空间）
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            group['name'], // 群名称
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (group['groupRemark'] != null &&
                              group['groupRemark']?.toString().trim() != '') // 群备注（条件显示）
                            Text(
                              '(${group['groupRemark']})',
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
  Widget buildWidget(BuildContext context) {
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
        title: const AppBarTitle('通讯列表'),
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
                onTap: () => Get.toNamed('/qr_code_scan'),
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
                onTap: ()=> Get.toNamed('/add_friend'),
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

              // 菜单项3: 添加群聊
              PopupMenuItem(
                value: 3,
                height: 40,
                onTap: () => Get.toNamed('/add_group'),
                child: const Row(
                  children: [
                    Icon(Icons.groups, size: 20),
                    SizedBox(width: 12),
                    Text('添加群聊', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              // 分割线
              _buildPopupDivider(),

              // 菜单项4: 创建群聊
              PopupMenuItem(
                value: 2,
                height: 40,
                onTap: () async {
                  var result = await Get.toNamed('/create_chat_group');
                  if (result != null && result) controller.onChatGroupList();
                },
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
              children: List.generate(controller.tabs.length, (index) {
                return Expanded( // 每个标签平均分配宽度
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 300),  // 动画时长300ms
                        alignment: Alignment.center,                  // 居中对齐
                        child: GestureDetector(
                          onTap: () => controller.handlerTabTapped(index), // 点击时调用切换方法
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),  // 动画时长
                            curve: Curves.easeInOut,                      // 动画曲线：缓入缓出
                            padding: const EdgeInsets.all(5),              // 内边距5px
                            margin: EdgeInsets.symmetric(
                              horizontal: index == controller.selectedIndex ? 4.0 : 0.0,  // 选中时增加水平外边距
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),      // 圆角1px
                              color: Colors.transparent,                    // 透明背景
                              border: Border(
                                bottom: BorderSide(                         // 底部边框（下划线）
                                  color: index == controller.selectedIndex
                                      ? theme.primaryColor           // 选中时蓝色
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
                                  color: index == controller.selectedIndex
                                      ? theme.primaryColor // 选中时蓝色
                                      : Colors.black,              // 未选中时黑色
                                  fontSize: 16,                    // 字号16px
                                ),
                                //长按导航栏进入分组
                                child: GestureDetector(
                                  onLongPress: controller.onLongPressGroup,
                                  child: Text(controller.tabs[index]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //右上角好友通知的红色提醒
                      if (index == 2)
                        Obx(() => globalData.getUnreadCount('friendNotify') > 0
                               || globalData.getUnreadCount('groupNotify') > 0
                            ? CustomTip(
                            globalData.getUnreadCount('friendNotify') + globalData.getUnreadCount('groupNotify'),
                            right: 7,
                            top: -2)
                            : const SizedBox.shrink()),
                    ],
                  )
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
                // 三个 Tab 根节点都是 RefreshIndicator，必须加 Key，否则切换「好友通知」时子树复用错乱甚至崩溃
                child: KeyedSubtree(
                  key: ValueKey<String>(
                      controller.tabs[controller.selectedIndex]),
                  child: getContent(controller.tabs[controller.selectedIndex]),
                ),
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
