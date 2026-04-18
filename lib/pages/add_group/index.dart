import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_search_box/index.dart';
import '../../components/custom_text_button/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

class AddGroupPage extends CustomWidgetNew<AddGroupLogic> {
  AddGroupPage({super.key});

  //搜索项（点击后跳转群详情）
  Widget _buildSearchItem(dynamic group) => Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: () => controller.toGroupDetail(group),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  //群头像
                  CustomPortrait(portrait: group['portrait'] ?? ''),
                  const SizedBox(width: 12),
                  //群名称（+ 群备注）
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (group['groupRemark'] != null &&
                                group['groupRemark']
                                        ?.toString()
                                        .trim() !=
                                    '')
                              Text(
                                '(${group['groupRemark']})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (group['chatGroupNumber'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '群号：${group['chatGroupNumber']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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

  @override
  Widget buildWidget(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF9FBFF),
        appBar: AppBar(
          title: const AppBarTitle('群聊搜索'),
          centerTitle: true,
          actions: [
            CustomTextButton(
              '取消',
              onTap: () => Get.back(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 5.0),
              fontSize: 14,
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                //搜索框
                CustomSearchBox(
                  hintText: '群号/群名称',
                  onChanged: controller.onSearchGroup,
                ),

                //有搜索结果
                if (controller.searchList.isNotEmpty)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => Future.delayed(
                          const Duration(milliseconds: 700)),
                      color: theme.primaryColor,
                      child: ListView(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
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
                              .map((group) => _buildSearchItem(group)),
                        ],
                      ),
                    ),
                  ),

                //无搜索结果
                if (controller.searchList.isEmpty)
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
                            '暂无搜索结果',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
