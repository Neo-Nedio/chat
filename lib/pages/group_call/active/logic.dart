import 'package:get/get.dart';

import '../../../api/group_call_api.dart';
import '../../../components/custom_flutter_toast/index.dart';

class ActiveGroupCallLogic extends GetxController {
  final _groupCallApi = GroupCallApi();
  final loading = false.obs;

  late String sessionId;
  late String groupId;
  late String groupName;
  late bool isOwner;
  late Map<String, dynamic> members;
  final activeUsers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    sessionId = args['sessionId']?.toString() ?? '';
    groupId = args['groupId']?.toString() ?? '';
    groupName = args['groupName']?.toString() ?? '群通话';
    isOwner = args['isOwner'] == true;
    members = args['members'] is Map
        ? Map<String, dynamic>.from(args['members'])
        : <String, dynamic>{};

    final source = args['users'];
    if (source is List) {
      activeUsers.assignAll(source.map(_normalizeUser));
    }
  }

  Map<String, dynamic> _normalizeUser(dynamic raw) {
    final user = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final id = (user['userId'] ?? user['id'] ?? raw).toString();
    final member = members[id] is Map
        ? Map<String, dynamic>.from(members[id])
        : <String, dynamic>{};
    final groupNickname = member['groupName']?.toString().trim() ?? '';
    final remark = member['remark']?.toString().trim() ?? '';
    final name = (user['name'] ??
            member['name'] ??
            member['username'] ??
            id)
        .toString();
    return {
      ...member,
      ...user,
      'userId': id,
      'name': groupNickname.isNotEmpty
          ? groupNickname
          : remark.isNotEmpty
              ? remark
              : name,
      'portrait': user['portrait'] ??
          member['portrait'] ??
          member['avatar'] ??
          '',
    };
  }

  void join() {
    Get.toNamed('/group_call', arguments: {
      'sessionId': sessionId,
      'groupId': groupId,
      'callType': 'audio',
      'isSender': false,
      'groupName': groupName,
      'members': members,
    });
  }

  Future<void> hangup() async {
    if (loading.value) return;
    loading.value = true;
    try {
      final userIds = activeUsers
          .map((user) => user['userId'].toString())
          .toSet()
          .toList();
      final result = await _groupCallApi.hangup(groupId, userIds);
      if (result['code'] == 0) {
        Get.back();
      } else {
        CustomFlutterToast.showErrorToast(result['msg'] ?? '挂断通话失败');
      }
    } catch (_) {
      CustomFlutterToast.showErrorToast('挂断通话失败');
    } finally {
      loading.value = false;
    }
  }
}
