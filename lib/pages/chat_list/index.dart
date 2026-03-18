import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../components/custom_search_box/index.dart';


// 用户聊天信息模型
class ChatInfo {
  final String avatar;
  final String name;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  bool isTop;

  ChatInfo({
    required this.avatar,
    required this.name,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
    this.isTop = false,
  });
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  final List<ChatInfo> _chatList = [ChatInfo(
    avatar:
    "",
    name: "张三",
    lastMessage: "今天晚上有空吗？",
    lastTime: "12:30",
    unreadCount: 2,
    isTop: true,
  ),
    ChatInfo(
      avatar:
      "",
      name: "李四",
      lastMessage: "项目进展如何？",
      lastTime: "11:20",
      unreadCount: 0,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "",
      name: "王五",
      lastMessage: "好的，收到了",
      lastTime: "昨天",
      unreadCount: 1,
    ),
    ChatInfo(
      avatar:
      "",
      name: "张三",
      lastMessage: "今天晚上有空吗？",
      lastTime: "12:30",
      unreadCount: 2,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "",
      name: "李四",
      lastMessage: "项目进展如何？",
      lastTime: "11:20",
      unreadCount: 0,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "",
      name: "王五",
      lastMessage: "好的，收到了",
      lastTime: "昨天",
      unreadCount: 1,
    ),
    ChatInfo(
      avatar:
      "",
      name: "张三",
      lastMessage: "今天晚上有空吗？",
      lastTime: "12:30",
      unreadCount: 2,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "",
      name: "李四",
      lastMessage: "项目进展如何？",
      lastTime: "11:20",
      unreadCount: 0,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "",
      name: "王五",
      lastMessage: "好的，收到了",
      lastTime: "昨天",
      unreadCount: 1,
    ),
    ChatInfo(
      avatar:
      "",
      name: "张三",
      lastMessage: "今天晚上有空吗？",
      lastTime: "12:30",
      unreadCount: 2,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "",
      name: "李四",
      lastMessage: "项目进展如何？",
      lastTime: "11:20",
      unreadCount: 0,
      isTop: true,
    ),
    ChatInfo(
      avatar:
      "=",
      name: "王五",
      lastMessage: "好的，收到了",
      lastTime: "昨天",
      unreadCount: 1,
    ),
    ChatInfo(
      avatar:
      "",
      name: "张三",
      lastMessage: "今天晚上有空吗？",
      lastTime: "12:30",
      unreadCount: 2,
      isTop: true,
    ),
    ChatInfo(
      avatar:
          "",
      name: "李四",
      lastMessage: "项目进展如何？",
      lastTime: "11:20",
      unreadCount: 0,
      isTop: true,
    ),
    ChatInfo(
      avatar:
          "",
      name: "王五",
      lastMessage: "好的，收到了",
      lastTime: "昨天",
      unreadCount: 1,
    ),];

  void _toggleTopStatus(int index) {
    setState(() {  // 触发UI重建
      _chatList[index].isTop = !_chatList[index].isTop;  // 切换置顶状态
      _sortChatList();  // 重新排序
    });
  }

  void _deleteChat(int index) {
    setState(() {
      _chatList.removeAt(index);  // 从列表中移除指定项
    });
  }

  void _sortChatList() {
    _chatList.sort((a, b) {  // 排序规则：置顶的排前面
      if (a.isTop && !b.isTop) return -1;  // a置顶b不置顶，a在前
      if (!a.isTop && b.isTop) return 1;   // a不置顶b置顶，b在前
      return 0;  // 状态相同，保持原顺序
    });
  }

  @override
  Widget build(BuildContext context) {
    // 从_chatList中筛选出所有isTop为true的聊天，转换成新列表
    List<ChatInfo> topList = _chatList.where((chat) => chat.isTop).toList();
    // 从_chatList中筛选出所有isTop为false的聊天，转换成新列表
    List<ChatInfo> normalList = _chatList.where((chat) => !chat.isTop).toList();

/*
    ┌─────────────────────────────────────────────────┐
    │  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  󰀃  +   │  ← AppBar
    │                                                  │    标题+添加按钮
    ├─────────────────────────────────────────────────┤
    │                                                  │
    │  🔍 搜索                                        │  ← 搜索框
    │                                                  │
    │  置顶                                            │  ← 分组标题
    │                                                  │
    │  ┌───────────────────────────────────────────┐  │
    │  │  ●●●  张三                      14:30     │  │  ← 置顶聊天项1
    │  │       最后一条消息内容...           󰀃      │  │    （有未读红点）
    │  └───────────────────────────────────────────┘  │
    │                                                  │
    │  ┌───────────────────────────────────────────┐  │
    │  │  ●●●  李四                      昨天      │  │  ← 置顶聊天项2
    │  │       你好，在吗？                         │  │    （无未读）
    │  └───────────────────────────────────────────┘  │
    │                                                  │
    │  其他                                            │  ← 分组标题
    │                                                  │
    │  ┌───────────────────────────────────────────┐  │
    │  │  ●●●  王五                      12:05     │  │  ← 普通聊天项1
    │  │       周末有空吗？                   󰀃      │  │    （有未读红点）
    │  └───────────────────────────────────────────┘  │
    │                                                  │
    │  ┌───────────────────────────────────────────┐  │
    │  │  ●●●  赵六                      昨天      │  │  ← 普通聊天项2
    │  │       图片                                 │  │    （无未读）
    │  └───────────────────────────────────────────┘  │
    │                                                  │
    │  ┌───────────────────────────────────────────┐  │
    │  │  ●●●  钱七                      周一      │  │  ← 普通聊天项3
    │  │       收到，谢谢！                         │  │    （无未读）
    │  └───────────────────────────────────────────┘  │
    │                                                  │
    └─────────────────────────────────────────────────┘

    图例：
    ●●● = 头像（圆形）
    󰀃 = 红色未读红点
    + = 添加按钮
    🔍 = 搜索图标*/
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true, //  // 标题居中显示
        title: const Text('聊天列表'),
        backgroundColor: const Color(0xFFF9FBFF),
        // 应用栏右侧的操作按钮
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 32),
            onPressed: () {
              print('图标按钮被点击');
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Column(
          children: [
            //搜索框组件
            CustomSearchBox(
              isCentered: false,
              onChanged: (value) {
                print(value);
              },
            ),
            // Expanded让ListView填充剩余空间
            Expanded(
              child: ListView(
                children: [

                  if (topList.isNotEmpty) ...[
                    const Padding(
                      // 显示"置顶"标题
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "置顶",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C9BFF),
                        ),
                      ),
                    ),
                    // 遍历topList，为每个chat创建列表项
                    // 使用展开操作符...将生成的组件列表展开
                    ...topList.map((chat) =>
                        _buildChatItem(chat, _chatList.indexOf(chat))),
                  ],

                  if (normalList.isNotEmpty) ...[
                    const Padding(
                      // "其他"标题
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "其他",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C9BFF),
                        ),
                      ),
                    ),
                    ...normalList.map((chat) =>
                        _buildChatItem(chat, _chatList.indexOf(chat))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/*  正常状态（未滑动）：
  ┌─────────────────────────────────────────────────┐
  │  ┌───────────────────────────────────────────┐  │
  │  │  ●●●  张三                      14:30     │  │
  │  │       最后一条消息内容...           󰀃 3   │  │
  │  └───────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────┘

  向左滑动后（正确效果）：
  ┌─────────────────────────────────────────────────┐
  │  ┌───────────────────────────────────────────┐  │
  │  │  ●●●  张三                      14:30     │  │  [置顶]  [删除]
  │  │       最后一条消息内容...           󰀃 3   │  │  ← 按钮在右侧
  │  └───────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────┘*/

  //构建可滑动的聊天项
  Widget _buildChatItem(ChatInfo chat, int index) {
    // 返回Slidable组件（可左右滑动的组件）
    return Slidable(
      key: ValueKey(index),
      // 结束滑动的操作面板（右滑菜单）
      endActionPane: ActionPane(
        motion: const ScrollMotion(),  // 滑动动画效果
        // extentRatio: chat.isTop ? 0.625 : 0.5,
        children: [
          // 第一个滑动按钮
          SlidableAction(
            padding: const EdgeInsets.all(0),  // 内边距为0
            onPressed: (context) => _toggleTopStatus(index),  // 点击调用置顶切换
            backgroundColor: Color(0xFF4C9BFF),  // 蓝色背景
            foregroundColor: Colors.white,        // 白色图标和文字
            // 根据置顶状态显示不同的图标：置顶显示图钉，不置顶显示空心图钉
            icon: chat.isTop ? Icons.push_pin_outlined : Icons.push_pin,
            // 根据置顶状态显示不同的文字
            label: chat.isTop ? '取消置顶' : '置顶',
          ),
          // 第二个滑动按钮（删除）
          SlidableAction(
            padding: const EdgeInsets.all(0),
            onPressed: (context) => _deleteChat(index),  // 点击调用删除
            backgroundColor: const Color(0xFFFF4C4C),    // 红色背景
            foregroundColor: Colors.white,                // 白色图标和文字
            icon: Icons.delete,  // 垃圾桶图标
            label: '删除',        // 文字标签
          ),
        ],
      ),

      // 列表项的主要内容
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),  // 上下内边距10
          decoration: BoxDecoration(  // 容器装饰
            color: Colors.white,      // 白色背景
            borderRadius: BorderRadius.circular(12.0),  // 圆角12
            border: Border(
              // 底部边框
              bottom: BorderSide(
                color: Colors.grey[200]!,  // 浅灰色
                width: 0.5,                // 边框宽度0.5
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row( // 水平排列
              children: [
                // 圆角头像
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),  // 圆角25（圆形）
                  child: CachedNetworkImage(  // 缓存网络图片
                    imageUrl: chat.avatar,     // 头像URL
                    width: 50,                  // 宽50
                    height: 50,                 // 高50
                    fit: BoxFit.cover,          // 图片铺满整个区域
                    // 图片加载时的占位组件
                    placeholder: (context, url) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],  // 灰色背景
                      child: const Center(       // 居中显示
                        child: CircularProgressIndicator(  // 圆形进度条
                          color: Color(0xffffffff),        // 白色
                          strokeWidth: 2,                   // 线条粗细2
                        ),
                      ),
                    ),
                    // 图片加载失败时的占位组件
                    errorWidget: (context, url, error) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],  // 灰色背景
                      child: Image.asset('assets/images/default-portrait.jpeg'), // 默认头像
                    ),
                  ),
                ),

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
                          Text(  // 用户名
                            chat.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,  // 中等粗细
                            ),
                          ),
                          Text(  // 最后消息时间
                            chat.lastTime,
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
                              chat.lastMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],  // 灰色文字
                              ),
                              maxLines: 1,                 // 最多显示1行
                              overflow: TextOverflow.ellipsis,  // 超出显示省略号
                            ),
                          ),
                          // 如果有未读消息
                          if (chat.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.all(6),  // 内边距6
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF4C4C),  // 红色背景
                                shape: BoxShape.circle,      // 圆形
                              ),
                              child: Text(  // 显示未读数量
                                chat.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,  // 白色文字
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
