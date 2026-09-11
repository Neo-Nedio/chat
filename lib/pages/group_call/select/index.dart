import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class GroupCallSelectPage extends CustomWidget<GroupCallSelectLogic> {
  GroupCallSelectPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        centerTitle: true,
        title: AppBarTitle('选择群通话成员'),
        actions: [
          CustomTextButton(
            '确定',
            onTap: controller.confirm,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            fontSize: 14,
          ),
        ],
      ),
      body: GetBuilder<GroupCallSelectLogic>(
        builder: (controller) {
          if (controller.members.isEmpty) {
            return const Center(child: Text('没有可邀请的群成员'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: controller.members.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final member = controller.members[index];
              final id = member['id'].toString();
              final selected = controller.selectedUserIds.contains(id);
              final remark = member['remark']?.toString() ?? '';
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => controller.toggleMember(id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selected,
                          activeColor: theme.primaryColor,
                          onChanged: (_) => controller.toggleMember(id),
                        ),
                        CustomPortrait(
                          portrait: member['portrait']?.toString() ?? '',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            remark.isEmpty
                                ? member['name'].toString()
                                : '${member['name']} ($remark)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
