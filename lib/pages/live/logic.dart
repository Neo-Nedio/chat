import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../api/live_api.dart';

class LiveLogic extends GetxController {
  final LiveApi _liveApi = LiveApi();
  final RxList<Map<String, dynamic>> rooms = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  Future<void> loadRooms() async {
    isLoading.value = true;
    try {
      final result = await _liveApi.list();
      final data = result['data'];
      if (result['code'] == 0 && data is List) {
        // data 对应后端的 LiveRoomDto[]。
        rooms.assignAll(data
            .whereType<Map>()
            .map((room) => Map<String, dynamic>.from(room)));
      } else {
        rooms.clear();
      }
    } catch (e) {
      rooms.clear();
      debugPrint('load live rooms error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
