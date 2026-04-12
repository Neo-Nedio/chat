import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_search_box/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

//用户选择页面，用于多选好友，支持搜索和确认选择。
class UserSelectPage extends CustomWidget<UserSelectLogic> {
  UserSelectPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      //标题栏
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        title: const AppBarTitle('选择好友'),
        centerTitle: true,
        //右侧返回按钮
        actions: [
          CustomTextButton(
              '确定',
              onTap: () => Get.back(result: controller.selectedUsers), // 返回选中用户
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              fontSize: 14),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            //搜索框
            CustomSearchBox(
              isCentered: false,
              onChanged: (value) => {controller.handlerSearchUser(value)},
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.userList.length,
                itemBuilder: (context, index) {
                  return _buildUserItem(controller.userList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //用户项组件
  Widget _buildUserItem(dynamic user) {
    //用来标识禁止操作的用户
    bool isOnly = controller.onlyUsers.any((id) => id == user['friendId']);
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          //可操作时才能点击
          if (!isOnly) controller.handlerSelectUser(user); // 点击选中/取消
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
                // 复选框
                Checkbox(
                  //不可操作时为灰色
                  checkColor: isOnly ? Colors.grey : theme.primaryColor, // 选中时对勾的颜色
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return  isOnly
                          ? Colors.grey.withValues(alpha: 0.1)  //不可操作时为灰色
                          : theme.searchBarColor; // 选中时背景色
                    }
                    return Colors.transparent; // 未选中时透明
                  }),
                  side: const BorderSide( //边框
                    width: 1.5,
                    color: Colors.grey,
                  ),
                value: isOnly
                    ? true //// 如果是禁用用户，固定显示为选中状态
                    : controller.selectedUsers.any((selected) => // 否则根据是否已选中来决定
                selected['friendId'] == user['friendId']),
                onChanged: (_) { //可操作时可切换
                  if (!isOnly) controller.handlerSelectUser(user); //切换选中状态
                },
                ),

                // 头像
                CustomPortrait(portrait: user['portrait']),

                const SizedBox(width: 12),

                // 昵称和备注
                Expanded(
                  child: Row(
                        children: [
                          //昵称
                          Text(
                            user['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          //根据条件展示备注
                          if (user['remark'] != null &&
                              user['remark']?.toString().trim() != '')
                            Text(
                              '(${user['remark']})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
