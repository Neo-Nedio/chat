// ignore_for_file: unnecessary_new, avoid_function_literals_in_foreach_calls
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../api/friend_api.dart';
import '../../../../components/custom_flutter_toast/index.dart';
import '../../../../utils/extension.dart';
import '../../../../utils/getx_config/config.dart';
import '../logic.dart';
import 'index.dart';

class ChatGroupSelectUserLogic extends Logic<ChatGroupSelectUserPage> {
  final _friendApi = FriendApi();

  final TextEditingController searchBoxController =  TextEditingController();

  final CreateChatGroupLogic createChatGroupLogic = GetInstance().find<CreateChatGroupLogic>();

  //所有的分组以及好友
  List<dynamic> friendList = [];

  //搜索结果
  List<dynamic> searchList = [];

  //建群聊时邀请的用户
  late List<dynamic> users = [];

  //选中的用户头像占用的宽度
  double _userTapWidth = 0;
  double get userTapWidth => _userTapWidth;
  set userTapWidth(double value) {
    _userTapWidth = value;
    update([const Key("chat_group_select_user")]);
  }

  //初始化方法 当退回该页面的时候 使用controller.init()进行页面刷新
  void init() {
    _getFriendList();
    _getSelectUser();
  }

  //获取所有分组以及好友
  void _getFriendList() async {
    final result = await _friendApi.list();
    if (result['code'] == 0) {
      friendList = result['data'];
      update([const Key("chat_group_select_user")]);
    }
  }

  //从创建群聊页面同步已选中的好友
  void _getSelectUser() {
    if (createChatGroupLogic.users.isNotEmpty) {
      users = createChatGroupLogic.users.copy();
    }
    userTapWidth = users.length * 40;
  }

  //添加到选中的用户中
  void addUsers(dynamic user) {
    user['isDelete'] = false;
    if (users.include(user as Map)) return; //判断是否存在
    users.add(user as Map<String, dynamic>);
    userTapWidth += 40; // 每个头像占40px
  }

  //删除选中的用户
  void subUsers(dynamic user) {
    // 1. 空列表保护
    if (users.isEmpty) return;

    // 2. 删除指定用户（点击头像触发）
    if (user != null) {
      users.delete(user);        // 使用扩展方法删除
      userTapWidth -= 40;        // 减少宽度
      return;
    }

    // 3. 按删除键触发（user == null）
    // 获取最后一个用户
    if (users[users.length - 1]['isDelete']) {
      // 已经标记过 → 直接删除
      users.removeAt(users.length - 1);
      userTapWidth -= 40;
    } else {
      // 未标记 → 先标记为灰色
      users[users.length - 1]['isDelete'] = true;
      update([const Key("chat_group_select_user")]);  // 刷新 UI
    }
  }

  //当被选中时进行的操作
  void onSelect(dynamic user) {
    //不存在时删除
    if (!users.include(user)) {
      addUsers(user);
      return;
    }
    //存在时加入
    subUsers(user);
  }

  //监听键盘删除键 事件
  //当用户在搜索框中按下删除键时，触发撤销最后一个选中的好友。
  void onBackKeyPress(KeyEvent event) {
    if (event is KeyUpEvent && searchBoxController.text.isEmpty) {
      subUsers(null);
    }
  }

  //提交选择，并返回数据
  void onSubmitPress() {
    createChatGroupLogic.users = users;
    Get.back();
  }

  //搜索好友
  void onSearchFriend(String friendInfo) {
    //无搜索内容时为空
    if (friendInfo.trim() == '') {
      searchList = [];
      _getFriendList();
      return;
    }

    // 搜索前重置最后一个好友的删除标记
    // 避免搜索时还显示灰色状态
    if (users.isNotEmpty) users[users.length - 1]['isDelete'] = false;

    _friendApi.search(friendInfo).then((res) {
      if (res['code'] == 0) {
        friendList = [];              // 清空分组列表（只显示搜索结果）
        searchList = res['data'];     // 设置搜索结果
        update([const Key("chat_group_select_user")]);
      }
    });
  }

  //按分组批量选择
  void onSelectGroup(dynamic group) {
    // 安全获取 friends 列表
    final List<dynamic>? friends =
    group['friends'] is List
        ? group['friends']
        : null;

    //空列表校验
    if (friends == null || friends.isEmpty) {
      CustomFlutterToast.showErrorToast('该群组没有成员');
      return;
    }

    //判断是否已全部选中
    bool allIncluded = friends.every((friend) => users.include(friend));
    if (allIncluded) {
      //  已全选 → 全部取消
      friends.forEach((friend) => onSelect(friend));
      return;
    }
    // 未全选 → 全部添加（只添加未选中的）
    friends.forEach((friend) => addUsers(friend));
  }

  //动态计算分组复选框的填充颜色：当分组内所有好友都被选中时，复选框显示主题色；否则透明。
  Color checkBoxFillColor(dynamic group) {
    try {
      //安全获取 friends 列表
      final List<dynamic>? friends = group['friends'] as List<dynamic>?;

      // 空列表处理
      if (friends == null || friends.isEmpty) return Colors.transparent;

      // 检查是否全部选中
      bool allIncluded = friends.every((friend) => users.include(friend));

      //返回对应颜色
      return allIncluded ? theme.primaryColor : Colors.transparent;

    } catch (e) {
      //异常处理
      return theme.searchBarColor;  // ← 备用颜色
    }
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  @override
  void onClose() {
    super.onClose();
    createChatGroupLogic.update([const Key('create_chat_group')]);
    searchBoxController.dispose();
    users = [];
  }
}
