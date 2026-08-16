import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_button/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

//AI 聊天页
class AiChatPage extends CustomWidget<AiChatLogic> {
  AiChatPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF9FBFF),
        //左上角返回键：退出 AI 聊天页
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        //标题展示当前选中模型名
        title: Obx(() => AppBarTitle(
            controller.currentModel.value?['modelName'] ?? 'AI 助手')),
        //右上角抽屉打开键
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            onPressed: () => controller.scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      //右侧滑栏：AI 模型列表（占屏宽 70%）
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              //标题区
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'AI 模型',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),

              //模型列表
              Expanded(
                child: Obx(() => controller.modelList.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无模型，点击下方添加~',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.modelList.length,
                        itemBuilder: (context, index) =>
                            _buildModelItem(controller.modelList[index]),
                      )),
              ),

              //底部添加模型按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: CustomButton(
                  text: '添加模型',
                  width: double.infinity,
                  height: 40,
                  textSize: 14,
                  onTap: () => controller.toModelEdit(),
                ),
              ),

            ],
          ),
        ),
      ),
      body: Column(
        children: [
          //聊天内容区
          Expanded(
            child: Obx(() {
              final itemCount = controller.records.length +
                  (controller.isStreaming.value ? 1 : 0);
              //需在 itemBuilder 外读取，Obx 才能追踪到 streamingContent 的变化
              final streamingContent = controller.streamingContent.value;
              if (itemCount == 0) {
                return const Center(
                  child: Text(
                    '向 AI 提一个问题吧~',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  //流式中的临时 assistant 气泡
                  if (index == controller.records.length) {
                    return _buildBubble({
                      'role': 'assistant',
                      'content': streamingContent,
                    });
                  }
                  return _buildBubble(controller.records[index]);
                },
              );
            }),
          ),

          //底部输入栏：左侧聊天框 + 右侧发送按钮
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: '向 AI 提问...',
                      controller: controller.questionController,
                      maxLines: 4,
                      minLines: 1,
                      vertical: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => GestureDetector(
                        onTap: controller.isStreaming.value
                            ? null
                            : controller.send,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.isStreaming.value
                                ? Colors.grey
                                : theme.primaryColor,
                          ),
                          child: controller.isStreaming.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //模型列表项：点击切换模型，右侧编辑/删除
  Widget _buildModelItem(Map<String, dynamic> model) {
    final isSelected = controller.currentModel.value?['id'] == model['id'];
    return GestureDetector(
      onTap: () => controller.selectModel(model),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.searchBarColor : const Color(0xFFF9FBFF),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: theme.primaryColor, width: 1)
              : null,
        ),
        child: Row(
          children: [
            //模型名 + 模型标识
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['modelName'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: const Color(0xFF1F1F1F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    model['model'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            //编辑
            GestureDetector(
              onTap: () => controller.toModelEdit(model),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.edit, size: 18, color: theme.primaryColor),
              ),
            ),
            //删除
            GestureDetector(
              onTap: () => controller.deleteModel(model),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.delete_outline,
                    size: 18, color: Color(0xFFFF4C4C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //聊天气泡：user 靠右（主题色），assistant 靠左（浅灰蓝）
  Widget _buildBubble(Map<String, dynamic> record) {
    final isUser = record['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.primaryColor : const Color(0xFFEDF2F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          record['content'] ?? '',
          style: TextStyle(
            fontSize: 15,
            color: isUser ? Colors.white : const Color(0xFF1F1F1F),
          ),
        ),
      ),
    );
  }
}