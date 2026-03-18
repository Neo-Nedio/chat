import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../api/chat_list_api.dart';
import '../../api/friend_api.dart';
import '../../components/custom_search_box/index.dart';
import '../../utils/date.dart';


final _chatListApi = ChatListApi();
final _friendApi = FriendApi();

//聊天主页面
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  late List<dynamic> _topList = [];     // 置顶聊天列表
  late List<dynamic> _otherList = [];   // 其他聊天列表
  late List<dynamic> _searchList = [];  // 搜索结果列表

  @override
  void initState() {
    super.initState();
    _onGetChatList();
  }

  void _onGetChatList() {
    //获取列表
    _chatListApi.list().then((res) {
      if (res['code'] == 0) {
        setState(() {
          _topList = res['data']['tops'];
          _otherList = res['data']['others'];
        });
      }
    });
  }

  void _onTopStatus(String id, bool isTop) {
    // 传入相反的状态更新指定状态
    _chatListApi.top(id, !isTop).then((res) {
      if (res['code'] == 0) {
        _onGetChatList(); // 重新获取最新列表
      }
    });
  }

  void _onDeleteChatList(String id) {
    _chatListApi.delete(id).then((res) {
      if (res['code'] == 0) {
        _onGetChatList(); // 重新获取最新列表
      }
    });
  }

  void _onSearchFriend(String friendInfo) {
    if (friendInfo.trim() == '') { // 搜索框为空
      setState(() {
        _searchList = []; // 清空搜索结果
      });
      return;
    }
    //获取搜索结果
    _friendApi.search(friendInfo).then((res) {
      if (res['code'] == 0) {
        setState(() {
          _searchList = res['data'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

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
        title: const Text('聊天列表'),
        backgroundColor: const Color(0xFFF9FBFF),
        // 应用栏右侧的操作按钮
        actions: [
          Theme( // 包裹PopupMenuButton，自定义主题
            data: Theme.of(context).copyWith(
              splashColor: const Color(0xFFEAEAEA),// 点击波纹效果的颜色
              highlightColor: const Color(0xFFEAEAEA), // 高亮颜色
            ),
            child: PopupMenuButton(
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
                  onTap: () {},       // 点击回调
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
                PopupMenuItem<int>(
                  enabled: false,
                  height: 1, // 禁用这个菜单项，以显示为分割线
                  child: Container(
                    height: 1,
                    padding: const EdgeInsets.all(0),
                    color: Colors.grey[300], // 设置分割线的颜色
                  ),
                ),

                //添加好友
                PopupMenuItem(
                  value: 1,           // 选中时的返回值
                  height: 40,         // 菜单项高度40像素
                  onTap: () {},       // 点击回调
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
                PopupMenuItem<int>(
                  enabled: false,
                  height: 1,
                  child: Container(
                    height: 1,
                    padding: const EdgeInsets.all(0),
                    color: Colors.grey[300],
                  ),
                ),

                //创建群聊
                PopupMenuItem(
                  value: 2,
                  height: 40,
                  onTap: () {},
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
                _onSearchFriend(value);
              },
            ),
            // Expanded让ListView填充剩余空间
            Expanded(
              //下拉刷新组件
              child: RefreshIndicator(
                onRefresh: () async {  // 下拉刷新时触发的回调函数
                  _onGetChatList();    // 调用API重新获取聊天列表
                  return Future.delayed(const Duration(milliseconds: 700)); // 延迟700ms返回
                },

                child: ListView(
                    children: [

                      if (_searchList.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "搜索结果",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C9BFF),
                            ),
                          ),
                        ),
                        //List 不能直接作为 child,所以要加上...展开成多个 Widget
                        ..._searchList.map((friend) =>
                            _buildSearchItem(friend, friend['friendId'])),
                      ],

                      if (_topList.isNotEmpty) ...[
                        const Padding(
                          // 显示"置顶"标题
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "置顶",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C9BFF),
                            ),
                          ),
                        ),
                        // 遍历topList，为每个chat创建列表项
                        // 使用展开操作符...将生成的组件列表展开
                        ..._topList
                            .map((chat) => _buildChatItem(chat, chat['id'])),
                      ],

                      if (_otherList.isNotEmpty) ...[
                        const Padding(
                          // "全部"标题
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "全部",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C9BFF),
                            ),
                          ),
                        ),
                        ..._otherList
                            .map((chat) => _buildChatItem(chat, chat['id'])),
                      ],
                    ],
                  ),
              )
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
            onPressed: (context) => _onTopStatus(id, chat['isTop']),  // 点击调用置顶切换
            backgroundColor: const Color(0xFF4C9BFF),  // 蓝色背景
            foregroundColor: Colors.white,        // 白色图标和文字
            // 根据置顶状态显示不同的图标：置顶显示图钉，不置顶显示空心图钉
            icon: chat['isTop'] ? Icons.push_pin_outlined : Icons.push_pin,
            // 根据置顶状态显示不同的文字
            label: chat['isTop'] ? '取消置顶' : '置顶',
          ),
          // 第二个滑动按钮（删除）
          SlidableAction(
            padding: const EdgeInsets.all(0),
            onPressed: (context) => _onDeleteChatList(id),  // 点击调用删除
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
          borderRadius: BorderRadius.circular(12),  // 和Material一致的圆角
          splashColor: const Color(0xFFEAEAEA),     // 点击波纹颜色（浅灰）
          highlightColor: const Color(0xFFEAEAEA),  // 点击高亮颜色（浅灰）
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),  // 圆角25（圆形）
                  child: CachedNetworkImage(  // 缓存网络图片
                    imageUrl: chat['portrait'],     // 头像URL
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
                            chat['remark'] ?? chat['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,  // 中等粗细
                            ),
                          ),
                          Text(  // 最后消息时间
                            DateUtil.formatTime(chat['createTime']),
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
                              chat['lastMsgContent']['content'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],  // 灰色文字
                              ),
                              maxLines: 1,                 // 最多显示1行
                              overflow: TextOverflow.ellipsis,  // 超出显示省略号
                            ),
                          ),
                          // 如果有未读消息
                          if (chat['unreadNum']  > 0)
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
        onTap: () {
          // 添加点击事件
        },
        borderRadius: BorderRadius.circular(12),  // 和Material一致的圆角
        splashColor: const Color(0xFFEAEAEA),     // 点击波纹颜色（浅灰）
        highlightColor: const Color(0xFFEAEAEA),  // 点击高亮颜色（浅灰）

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),// 圆角25（圆形，因为宽高50）
                  child: CachedNetworkImage(
                    imageUrl: friend['portrait'], // 从friend对象获取头像URL
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,

                    // 加载中的占位图
                    placeholder: (context, url) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],  // 灰色背景
                      child: const Center(
                        child: CircularProgressIndicator(  // 旋转加载圈
                          color: Color(0xffffffff),  // 白色
                          strokeWidth: 2,
                        ),
                      ),
                    ),

                    // 加载失败的占位图
                    errorWidget: (context, url, error) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Image.asset('assets/images/default-portrait.jpeg'),  // 默认头像
                    ),

                  ),
                ),

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
