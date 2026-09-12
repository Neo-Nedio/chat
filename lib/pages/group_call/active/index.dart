import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_portrait/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class ActiveGroupCallPage extends CustomWidget<ActiveGroupCallLogic> {
  ActiveGroupCallPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      appBar: AppBar(
        leading: IconButton(
          tooltip: '返回',
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Obx(
          () => Text('正在语音通话 (${controller.activeUsers.length})'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Obx(
                  () => Wrap(
                    spacing: 24,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: controller.activeUsers
                        .map(_buildMemberItem)
                        .toList(),
                  ),
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> user) => SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPortrait(
              size: 72,
              portrait: user['portrait']?.toString() ?? '',
            ),
            const SizedBox(height: 8),
            Text(
              user['name']?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      );

  Widget _buildActions(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.isOwner) ...[
              Obx(
                () => FloatingActionButton.extended(
                  heroTag: 'active-group-call-hangup',
                  backgroundColor: Colors.red,
                  onPressed: controller.loading.value
                      ? null
                      : controller.hangup,
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  label: const Text('挂断',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 32),
            ],
            FloatingActionButton.extended(
              heroTag: 'active-group-call-join',
              backgroundColor: theme.primaryColor,
              onPressed: controller.join,
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('加入',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
}
