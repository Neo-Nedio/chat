import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar_title/index.dart';
import '../../../../components/custom_portrait/index.dart';
import '../../../../components/custom_search_box/index.dart';
import '../../../../components/custom_text_button/index.dart';
import '../../../../utils/extension.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';

class ChatGroupSelectUserPage
    extends CustomWidgetNew<ChatGroupSelectUserLogic> {
  ChatGroupSelectUserPage({super.key});
/*
  ┌─────────────────────────────────────────────────┐
  │  [取消]         选择好友            [完成(2)]   │  ← AppBar
  ├─────────────────────────────────────────────────┤
  │  ┌─────────────────────────────────────────────┐│
  │  │  🔍 [搜索框]                                 ││  ← 搜索栏
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  │  ▼ 搜索结果（如果有）                           │
  │  ┌─────────────────────────────────────────────┐│
  │  │ ☑️ [头像] 张三 (备注名)                     ││  ← 好友项
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  │  ▼ 分组（可展开）                               │
  │  ┌─────────────────────────────────────────────┐│
  │  │ ☑️ 同事组 (3)                               ││  ← 分组标题
  │  │   ├─ ☑️ [头像] 李四                         ││  ← 组内好友
  │  │   ├─ ☐ [头像] 王五                         ││
  │  │   └─ ☐ [头像] 赵六                         ││
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  └─────────────────────────────────────────────────┘*/

  //好友项
  Widget _buildFriendItem(dynamic friend) => Material(
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
    child: InkWell(
      onTap: () => controller.onSelect(friend),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5), //白色边框
          ),
        ),
        child: Row(
          children: [
            //复选框
            Checkbox(
              value: controller.users.include(friend), //是否保护
              onChanged: (value) => controller.onSelect(friend), //选择/取消
              //选中时显示主题色，否则透明
              //WidgetStateProperty.all 是 Flutter 中用于为所有交互状态返回相同样式的工具类。
              fillColor: WidgetStateProperty.all(
                controller.users.include(friend)
                    ? theme.primaryColor
                    : Colors.transparent,
              ),
              // 点击波纹半径
              splashRadius: 5,
            ),

            //头像
            CustomPortrait(url: friend['portrait']),

            const SizedBox(width: 12),

            //名字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend['name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (friend['remark'] != null && friend['remark'].toString().trim() != '')
                    Text(
                      '(${friend['remark']})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget buildWidget(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FBFF),
    appBar: AppBar(
      //左上角取消按钮
      leading: TextButton(
        child: Text(
          '取消',
          style: TextStyle(color: theme.primaryColor),
        ),
        onPressed: () => Get.back(),
      ),
      centerTitle: true,
      title: const AppBarTitle('选择好友'),
      backgroundColor: const Color(0xFFF9FBFF),
      //完成按钮
      actions: [
        CustomTextButton(
          '完成(${controller.users.length})',
          onTap: controller.onSubmitPress,
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 5.0),
          fontSize: 14),],
    ),

    body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Column(
        children: [
          // 搜索框区域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: controller.onBackKeyPress, // 监听删除键
                  child: CustomSearchBox(
                    textEditingController: controller.searchBoxController,
                    // prefix: controller.users.isNotEmpty
                    //     ? SizedBox(
                    //         height: 36.8,
                    //         width: controller.userTapWidth >= 200
                    //             ? 210
                    //             : controller.userTapWidth,
                    //         child: ListView(
                    //           scrollDirection: Axis.horizontal,
                    //           children: controller.users
                    //               .map((user) => _selectedUserItem(user))
                    //               .toList(),
                    //         ),
                    //       )
                    //     : null,
                    isCentered: false,
                    onChanged: (value) => controller.onSearchFriend(value), // 实时搜索
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          //好友列表区域
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ListView(
                children: [
                  //有搜索结果 → 显示搜索结果
                  if (controller.searchList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "搜索结果",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    ...controller.searchList
                        .map((friend) => _buildFriendItem(friend)),
                  ],

                  //无搜索结果 → 显示分组列表
                  ...controller.friendList.map((group) {
                    return GestureDetector(
                      onLongPress: () => controller.onSelectGroup(group), //长按 选择/取消
                      //分组组件
                      child: ExpansionTile(
                        iconColor: theme.primaryColor, //图标颜色（展开/收起的箭头图标）
                        visualDensity: const VisualDensity( //紧凑布局密度（减小内边距）
                            horizontal: 0, vertical: -4),
                        dense: true,  //使用紧凑样式
                        collapsedShape: RoundedRectangleBorder( //未展开时的边框形状
                          borderRadius: BorderRadius.circular(8),
                        ),
                        shape: RoundedRectangleBorder(         //展开时的边框形状
                          borderRadius: BorderRadius.circular(8),
                        ),
                        //标题行
                        title: Row(
                          children: [
                            // 复选框
                            Checkbox(
                              value: group['friends'].isNotEmpty &&
                              group['friends'].every((friend) => controller.users.include(friend)),
                              onChanged: (value) => controller.onSelectGroup(group),
                              fillColor: WidgetStateProperty.all( //填充颜色
                                group['friends'].isNotEmpty &&
                                    group['friends'].every((friend) => controller.users.include(friend))
                                    ? theme.primaryColor
                                    : Colors.transparent,
                              ),
                              splashRadius: 5,
                            ),
                            //分组名字
                            Text(
                              '${group['name']}（${group['friends'].length}）',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        //内部成员
                        children: [
                          ...group['friends'].map(
                                (friend) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0),
                              child: _buildFriendItem(friend),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
