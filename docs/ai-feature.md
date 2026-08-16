# AI 功能开发文档（Flutter 端）

> 对应接口文档：`chat-server/docs/ai-api.md`
> API 层已完成：`lib/api/ai_api.dart`（`AiApi` 单例，含模型增删改查、聊天记录、同步问答、SSE 流式问答）
> 技术栈约定：GetX（路由 / 状态 / 依赖注入），页面规范为 `pages/xxx/index.dart + logic.dart`，统一走 `ControllerBinding`

---

## 1. 功能结构总览

```
导航层（navigation）
└── 底部 Tab 栏中间凹槽 + 圆形 AI 按钮 ──点击──> /ai_chat

AI 聊天页（pages/ai_chat）
├── 左侧滑栏 Drawer（占屏宽 70%）
│   ├── AI 模型列表（从上到下）
│   │   └── 每个模型项：点击切换模型 | 右侧「编辑」「删除」
│   └── 底部「添加模型」按钮 ──> /ai_model_edit（新增模式）
├── 聊天内容区（历史记录，user 右 / assistant 左）
└── 底部输入栏：左侧聊天输入框 + 右侧发送按钮（SSE 流式）

模型编辑页（pages/ai_chat/ai_model_edit）
├── 新增模式（无入参）
└── 编辑模式（arguments 传入模型数据）
```

## 2. 底部导航栏改造（凹槽 + 圆形 AI 按钮）

现状：`lib/pages/navigation/index.dart` 使用 `BottomNavigationBar`，4 个 Tab（消息 / 通讯 / 说说 / 我的），图标与文案在 `logic.dart` 的 `selectedIcons / unselectedIcons / name` 中。

改造方案：**AI 按钮不是第 5 个 Tab，不进入 `currentIndex` 切换体系**，点击后 `Get.toNamed('/ai_chat')` 跳转独立页面。

- 保留现有 `BottomNavigationBar`，中间位置插入一个**占位 item**（空 icon、空 label，禁止点击）形成视觉缺口，左右各 2 个真实 Tab
- 用 `Stack` 在 `bottomNavigationBar` 上层居中叠一个**圆形悬浮按钮**（类似 FAB 居中凹槽效果）：
  - 圆形按钮直径约 56，向上凸出导航栏一半，带阴影
  - 图标使用 AI 主题资源（需新增 `assets/images/ai-blue.png` / `ai-pink.png`，随主题切换）
  - 点击 `Get.toNamed('/ai_chat')`
- 占位 item 的 onTap 拦截：`BottomNavigationBar.onTap` 中判断若是占位下标则忽略，真实下标需换算回 `currentIndex`（0、1、2、3 与占位穿插后的映射）

## 3. AI 聊天页（pages/ai_chat）

路由：`/ai_chat`，注册到 `route.dart`，`binding: ControllerBinding()`。

页面结构：`Scaffold` + `drawer` + 消息列表 + 底部输入栏。

### 3.1 进入流程（状态机）

```
onInit
  └─> 加载聊天记录（2.1 chatRecordList）
      加载模型列表（1.1 modelList）
  └─> 页面首帧渲染完成后：自动打开侧滑栏（scaffoldKey.currentState?.openDrawer()）
      └─> 模型列表加载完成后：默认选中第一个模型
           └─> 模型列表为空：停留在侧滑栏，引导点击「添加模型」
```

- 「进入时直接打开侧滑栏」在 `addPostFrameCallback` 中执行，避免 build 期间操作 Scaffold
- 用户点击某模型项 = 切换当前模型 + 关闭侧滑栏

### 3.2 左侧滑栏（Drawer，占屏宽 70%）

- 用 `Drawer(width: MediaQuery.of(context).size.width * 0.7)` 或 `SizedBox` 包裹控制宽度
- 内容从上到下：
  - 顶部标题区（「AI 模型」+ 当前选中模型名）
  - 模型列表 `ListView`：每项左侧模型名 + model 标识，右侧两个操作：
    - **编辑**：跳 `/ai_model_edit`，arguments 携带该模型完整数据，返回后刷新列表
    - **删除**：弹确认框 → `modelDelete(id)` → 刷新列表；若删除的是当前选中模型，则重置选中为新的第一个（列表为空则清空）
  - 选中态：当前模型项高亮（主题色描边/背景）
- 底部固定「添加模型」按钮（`CustomButton`）：跳 `/ai_model_edit`（无入参 = 新增模式），返回后刷新列表
- 侧滑栏打开时若列表为空，中间显示空态提示（参考项目 `chat-empty.png` 风格）

### 3.3 聊天内容区

- 进入时 `chatRecordList()` 拉全量历史，按时间正序渲染
- 气泡：`role == 'user'` 靠右（主题色），`role == 'assistant'` 靠左（灰白底）
- assistant 气泡需支持 markdown 样式可后置，第一版用普通 `Text`
- 历史为空：显示 AI 引导空态（如「向 AI 提一个问题吧」）

### 3.4 底部输入栏 + 流式发送

布局：底部安全区内 `Row`——左侧 `Expanded` 聊天输入框（`CustomTextField`，多行自适应），右侧圆形发送按钮。

发送流程（点击发送且 `question` 非空、已选中模型）：

```
1. 本地立即插入一条 user 气泡（乐观 UI），清空输入框
2. 追加一条空的 assistant 气泡，进入「流式中」状态（发送按钮禁用/转圈）
3. 调 AiApi().answersStream(modelId, question) 逐事件处理：
   - delta: 把 data['content'] 追加到当前 assistant 气泡（Obx 字符串累加，打字机效果）
   - done : 用 data 中的完整记录替换该气泡，解除流式状态
   - error: toast data['msg']，移除空的 assistant 气泡
4. 流式期间收到新消息不允许再次发送（置灰发送按钮）
```

- SSE 解析已在 `AiApi.answersStream` 内完成，logic 层只需 `await for (final e in ...)` 消费
- 页面销毁时取消流订阅（`onClose` 中 cancel）

## 4. 模型编辑页（pages/ai_chat/ai_model_edit）

路由：`/ai_model_edit`。

- 表单字段：`modelName`（显示名）、`baseUrl`（接口地址）、`apiKey`、`model`（模型标识），全部必填（新增模式）
- **新增模式**：无 arguments，四项全空 → `modelAdd(...)`
- **编辑模式**：arguments 传入模型数据，表单回填（apiKey 列表接口不返回，编辑时留空表示不修改）→ `modelUpdate(id, ...只传改动字段)`
- 成功后 toast + `Get.back(result: true)`，侧滑栏据返回值刷新列表

## 5. 涉及文件清单

| 动作 | 文件 |
|---|---|
| 已完成 | `lib/api/ai_api.dart` |
| 新增 | `lib/pages/ai_chat/index.dart`、`lib/pages/ai_chat/logic.dart` |
| 新增 | `lib/pages/ai_chat/ai_model_edit/index.dart`、`.../logic.dart` |
| 修改 | `lib/pages/navigation/index.dart`（凹槽 + 圆形按钮）、`logic.dart`（占位映射） |
| 修改 | `lib/utils/getx_config/route.dart`（注册 `/ai_chat`、`/ai_model_edit`） |
| 新增 | `assets/images/ai-blue.png`、`ai-pink.png`（圆形按钮图标，需先放入 assets） |

## 6. 注意事项

- 所有接口无需手动带 token，`Http.dart` 拦截器统一注入 `x-token`；`code == -1` 会自动跳登录
- `answersStream` 是 SSE 原始流，**不经过** `code` 拦截器，错误通过 `error` 事件下发，logic 层需自行 toast
- AI 页不属于底部 Tab 切换体系，从 AI 页返回后 `currentIndex` 保持不变
- 侧滑栏宽度按 `MediaQuery` 屏宽 × 0.7 计算，不要写死像素