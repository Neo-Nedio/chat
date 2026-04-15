import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/date.dart';
import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../custom_admin_drop_menu/index.dart';
import '../custom_portrait/index.dart';

class CustomUserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const CustomUserCard({super.key, required this.user});

  GlobalThemeConfig get theme => Get.find<GlobalThemeConfig>();

  //格式化生日
  String _formatBirthday(dynamic birthday) {
    if (birthday == null) return '';
    DateTime? birth;
    if (birthday is String) {
      birth = DateTime.tryParse(birthday);
    } else if (birthday is int) {
      birth = DateTime.fromMillisecondsSinceEpoch(birthday);
    }
    if (birth == null) return '';
    return '${birth.year}-${birth.month.toString().padLeft(2, '0')}-${birth.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────────────────┐
    │                    CustomUserCard                           │
    │                  (StatelessWidget)                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                             │
    │  ┌───────────────────────────────────────────────────────┐ │
    │  │  🎨 上部区域 (装饰背景: theme.minorColor)              │ │
    │  │  ┌─────────────────────────────────────────────────┐  │ │
    │  │  │ Row (顶部行)                                     │  │ │
    │  │  │  ┌──────────────────┐  ┌────────────────────┐  │  │ │
    │  │  │  │ 在线状态          │  │ 年龄 + 性别图标     │  │  │ │
    │  │  │  │ ● 在线/离线       │  │ 25岁 ♂/♀           │  │  │ │
    │  │  │  └──────────────────┘  └────────────────────┘  │  │ │
    │  │  └─────────────────────────────────────────────────┘  │ │
    │  │                      ↓                                  │ │
    │  │  ┌─────────────────────────────────────────────────┐  │ │
    │  │  │           CustomPortrait (头像)                  │  │ │
    │  │  │                80x80, 圆形                       │  │ │
    │  │  └─────────────────────────────────────────────────┘  │ │
    │  │                      ↓                                  │ │
    │  │  ┌─────────────────────────────────────────────────┐  │ │
    │  │  │              昵称 (name)                         │  │ │
    │  │  │           18px, 粗体, 黑色                       │  │ │
    │  │  └─────────────────────────────────────────────────┘  │ │
    │  │                      ↓                                  │ │
    │  │  ┌─────────────────────────────────────────────────┐  │ │
    │  │  │      账号 (account) - 13px, 灰色                 │  │ │
    │  │  │      生日 (birthday) - 13px, 灰色 (可选)         │  │ │
    │  │  │      邮箱 (email) - 13px, 灰色 (可选)            │  │ │
    │  │  └─────────────────────────────────────────────────┘  │ │
    │  └───────────────────────────────────────────────────────┘ │
    │                            ↓                                │
    │  ┌───────────────────────────────────────────────────────┐ │
    │  │  📊 下部区域 (3列等宽布局)                             │ │
    │  │  ┌──────────────┬──────────────┬──────────────────┐  │ │
    │  │  │   加入时长    │   用户状态    │    更多操作       │  │ │
    │  │  │              │              │                  │  │ │
    │  │  │    "365天"    │   "正常"     │   ▼ 下拉菜单      │  │ │
    │  │  │   (粗体18px)  │  (主题色)    │   "更多操作"      │  │ │
    │  │  │              │              │   (12px灰色)      │  │ │
    │  │  └──────────────┴──────────────┴──────────────────┘  │ │
    │  └───────────────────────────────────────────────────────┘ │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘*/
    final String name = user['name'] ?? '';
    final String account = user['account'] ?? '';
    final String portrait = user['portrait'] ?? '';
    final String sex = user['sex'] ?? '男';
    final String email = user['email'] ?? '';
    final String status = user['status'] ?? 'normal';
    final bool isOnline = user['isOnline'] == true;
    final String age = DateUtil.calculateAge((user['birthday']));
    final int joinedDays = DateUtil.calculateDaysSinceJoined(user['createTime']);
    final String birthdayStr = _formatBirthday(user['birthday']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow( //阴影：围绕卡片外层的投影效果
            color: theme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),//向下偏移
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上部：状态 + 头像 + 基本信息
          Container(
            width: double.infinity, //占满父容器
            //内边距：左12、上10、右12、下14
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: theme.minorColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only( //只有左上和右上两个角是12px
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // 顶部行：在线状态 + 年龄性别
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      //在线状态指示器
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 彩色圆点
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color(0xFF4CAF50)// 在线 → 绿色 (#4CAF50)
                                : Colors.grey,              // 离线 → 灰色
                            shape: BoxShape.circle,         // 圆形形状
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? '在线' : '离线',
                          style: TextStyle(
                            fontSize: 11,
                            color: isOnline
                                ? const Color(0xFF4CAF50)  // 在线 → 绿色
                                : Colors.grey,              // 离线 → 灰色
                          ),
                        ),
                      ],
                    ),
                    //年龄+性别显示
                    Row(
                      //年龄文字
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$age岁',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 2),
                        //性别图标
                        Icon(
                          sex == '女' ? Icons.female : Icons.male,
                          size: 14,
                          color: sex == '女'
                              ? const Color(0xFFFFA0CF)  // 女→粉色 (#FFA0CF)
                              : const Color(0xFF4C9BFF), // 男→蓝色 (#4C9BFF)
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                //头像
                CustomPortrait(portrait: portrait, size: 64, radius: 32),

                const SizedBox(height: 8),

                //昵称
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),

                const SizedBox(height: 2),

                //账号
                Text(
                  account,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),

                //生日（条件显示）
                if (birthdayStr.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    birthdayStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],

                //邮箱（条件显示）
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 下部：加入时长 + 用户状态 + 更多操作
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Row(
              children: [
                Expanded(
                  child: _buildBottomItem(
                    '$joinedDays天',
                    '加入时长',
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildBottomItem(
                    status == 'normal' ? '正常' : '禁用',
                    '用户状态',
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: status == 'normal'
                          ? theme.primaryColor
                          : theme.errorColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      AdminDropMenu(isDisable: status != 'normal'),
                      const SizedBox(height: 2),
                      const Text(
                        '更多操作',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem(String value, String label, TextStyle valueStyle) {
    return Column(
      children: [
        Text(value, style: valueStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
