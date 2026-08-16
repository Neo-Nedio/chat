import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'Http.dart';

//SSE 流式事件
//event: delta / done / error
//data: 事件对应的 JSON 数据（delta 为 {"content": "..."}，done 为完整回答记录，error 为 {"msg": "..."}）
class AiSseEvent {
  final String event;
  final Map<String, dynamic> data;

  AiSseEvent(this.event, this.data);
}

//AI 模块的api
class AiApi {
  final Dio _dio = Http().dio;
  //构建单例
  static final AiApi _instance = AiApi._internal();

  AiApi._internal();

  factory AiApi() {
    return _instance;
  }

  //我的模型列表（不返回 apiKey）
  // 返回 data 字段结构：
  //   id         - 模型配置 id
  //   modelName  - 显示名
  //   baseUrl    - OpenAI 兼容接口地址
  //   model      - 模型标识
  //   createTime - 创建时间
  Future<Map<String, dynamic>> modelList() async {
    final response = await _dio.get('/v1/api/ai/model/list');
    return response.data;
  }

  //新增模型配置
  Future<Map<String, dynamic>> modelAdd({
    required String modelName,
    required String baseUrl,
    required String apiKey,
    required String model,
  }) async {
    final response = await _dio.post(
      '/v1/api/ai/model/add',
      data: {
        'modelName': modelName,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'model': model,
      },
    );
    return response.data;
  }

  //编辑模型配置（只更新传入的字段，只能编辑自己的配置）
  Future<Map<String, dynamic>> modelUpdate({
    required String id,
    String? modelName,
    String? baseUrl,
    String? apiKey,
    String? model,
  }) async {
    final data = <String, dynamic>{'id': id};
    if (modelName != null) data['modelName'] = modelName;
    if (baseUrl != null) data['baseUrl'] = baseUrl;
    if (apiKey != null) data['apiKey'] = apiKey;
    if (model != null) data['model'] = model;

    final response = await _dio.post(
      '/v1/api/ai/model/update',
      data: data,
    );
    return response.data;
  }

  //删除模型配置
  Future<Map<String, dynamic>> modelDelete(String id) async {
    final response = await _dio.post(
      '/v1/api/ai/model/delete',
      data: {'id': id},
    );
    return response.data;
  }

  //我的聊天记录（按时间正序返回当前用户全部 AI 问答记录）
  // 返回 data 字段结构：
  //   id         - 记录 id
  //   userId     - 用户 id
  //   modelId    - 该条记录使用的模型配置 id
  //   role       - user = 用户提问，assistant = AI 回答
  //   content    - 内容
  //   createTime - 创建时间
  Future<Map<String, dynamic>> chatRecordList() async {
    final response = await _dio.get('/v1/api/ai/chat/record/list');
    return response.data;
  }

  //问答（同步），返回落库后的 AI 回答记录
  Future<Map<String, dynamic>> answers(String modelId, String question) async {
    final response = await _dio.post(
      '/v1/api/ai/chat/answers',
      data: {'modelId': modelId, 'question': question},
    );
    return response.data;
  }

  //问答（SSE 流式）
  // 逐事件 yield [AiSseEvent]：
  //   delta - 增量内容，data['content'] 拼接即为完整回答
  //   done  - 流结束，data 为完整回答记录（已落库）
  //   error - 出错，data['msg'] 为错误信息
  // 注意：SSE 响应体不是 {code, data} 结构，不会被响应拦截器处理
  Stream<AiSseEvent> answersStream(String modelId, String question) async* {
    final response = await _dio.post<ResponseBody>(
      '/v1/api/ai/chat/answers/stream',
      data: {'modelId': modelId, 'question': question},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    //SSE 以空行（\n\n）分隔事件，需跨数据块缓冲后再解析
    final buffer = StringBuffer();
    String? eventName;
    final dataLines = <String>[];

    await for (final chunk in utf8.decoder.bind(response.data!.stream)) {
      buffer.write(chunk);

      //循环取出完整的 SSE 事件块，不完整部分留在缓冲区
      String content = buffer.toString();
      int splitIndex;
      while ((splitIndex = content.indexOf('\n\n')) >= 0) {
        final rawEvent = content.substring(0, splitIndex);
        content = content.substring(splitIndex + 2);

        for (final line in rawEvent.split('\n')) {
          if (line.startsWith('event:')) {
            eventName = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataLines.add(line.substring(5).trim());
          }
        }

        if (eventName != null && dataLines.isNotEmpty) {
          final decoded =
              jsonDecode(dataLines.join('\n')) as Map<String, dynamic>;
          yield AiSseEvent(eventName, decoded);
        }
        eventName = null;
        dataLines.clear();
      }

      buffer
        ..clear()
        ..write(content);
    }
  }
}