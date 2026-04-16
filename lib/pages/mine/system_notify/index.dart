import 'package:flutter/material.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_notify_content/index.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class SystemNotifyPage extends CustomWidget<SystemNotifyLogic> {
  SystemNotifyPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: const AppBarTitle('系统通知'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9FBFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ...controller.systemNotifyList
                .map((notify) => _buildNotifyItem(notify)),

            if (controller.systemNotifyList.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('暂无公告', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifyItem(notify) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white,
          ),
          //通知创建时间
          child: Text(
            DateUtil.formatTime(notify['createTime']),
            style: const TextStyle(fontSize: 12),
          ),
        ),

        const SizedBox(height: 5),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          child: CustomNotifyContent.fromNotify(notify, titleSize: 24),
        ),

        const SizedBox(height: 15),
      ],
    );
  }
}
