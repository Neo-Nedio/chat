import 'package:get/get.dart';

class GroupCallSelectLogic extends GetxController {
  late List<Map<String, dynamic>> members;
  final selectedUserIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    final source = args['members'];
    final currentUserId = args['currentUserId']?.toString() ?? '';
    members = <Map<String, dynamic>>[];
    if (source is Map) {
      source.forEach((key, value) {
        final id = key.toString();
        if (id == currentUserId || value is! Map) return;
        final member = Map<String, dynamic>.from(value);
        members.add({
          'id': id,
          'name': member['name'] ?? member['username'] ?? id,
          'remark': member['remark'] ?? member['groupName'] ?? '',
          'portrait': member['portrait'] ?? member['avatar'] ?? '',
        });
      });
    }
  }

  void toggleMember(String userId) {
    if (!selectedUserIds.add(userId)) selectedUserIds.remove(userId);
    update();
  }

  void confirm() {
    Get.back(result: selectedUserIds.toList());
  }
}
