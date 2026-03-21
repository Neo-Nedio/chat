import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'GlobalThemeConfig.dart';
import 'route.dart';



typedef InitFunc = void Function();          // 初始化函数
typedef CloseFunc = void Function();         // 关闭函数
typedef CallbackFunc = void Function();      // 回调函数
typedef FilterFunc<T> = Object Function(T value);  // 过滤器函数

//路由配置
// 进入路由时，GetX会自动：
// 1. 执行 ControllerBinding().dependencies()
// 2. 注册所有需要的控制器
// 3. 然后才创建 Page
// 4. 页面中直接 Get.find() 就能拿到
List<GetPage> pageRoute =AppRoutes.pageRoute;

//路由监听
void routingCallback(router) {
  // 每次路由变化时打印日志
  debugPrint("enter>>>>>>>>>>>>>>>>${router.current}");
}

// 通过内置GetBuilder来构建，配合GetView使用
// 与业务逻辑绑定，通过GetX实现状态管理，这样页面只负责渲染，业务逻辑全部在控制器中实现
// 封装了GetBuilder的所有细节
abstract class CustomWidget<T extends GetxController> extends StatelessWidget {
  // 构造函数
  CustomWidget({this.key, this.widgetFilter}) : super(key: key);

  // 当传入key的时候，若更新widget需使用controller.update([key],)
  @override
  final Key? key;                    // 组件Key
  final dynamic arguments = Get.arguments;  // 路由参数
  final String? tag = null;           // 控制器标签
  late final FilterFunc? widgetFilter; // 过滤器

  // 获取控制器
  ///控制器就是对应的logic对象
  T get controller => GetInstance().find<T>(tag: tag);
  GlobalThemeConfig get theme =>
      GetInstance().find<GlobalThemeConfig>(tag: tag);

  /// 生命周期方法
  // 初始化
  void init(BuildContext context) {}
  // 依赖发生变化
  void didChangeDependencies(BuildContext context) {}
  // 更新Widget
  void didUpdateWidget(
    GetBuilder oldWidget,
    GetBuilderState<T> state,
  ) {}
  // 关闭
  void close(BuildContext context) {}

  // 构建widget 子类必须实现
  Widget buildWidget(BuildContext context);

  // 创建上下文
  @override
  StatelessElement createElement() => StatelessElement(this);

  // 构建
  @override
  Widget build(BuildContext context) => GetBuilder<T>(
        id: key, // 指定更新ID
        filter: widgetFilter, // 过滤器
        initState: (GetBuilderState<T> state) => init(context), // 初始化
        didChangeDependencies: (GetBuilderState<T> state) =>
            didChangeDependencies(context),
        didUpdateWidget: didUpdateWidget,
        builder: (controller) { // 构建UI
          return buildWidget(context);
        },
        dispose: (GetBuilderState<T> state) => close(context), // 销毁
      );
}

//让与颜色相关的widget内部封装有获取全局颜色配置的方法
abstract class StatelessThemeWidget extends StatelessWidget {
  const StatelessThemeWidget({super.key});
  GlobalThemeConfig get theme => GetInstance().find<GlobalThemeConfig>();
}


// 继承自GetView
// 适用于局部
abstract class CustomWidgetObx<T extends GetxController> extends GetView<T> {
  const CustomWidgetObx({required Key key}) : super(key: key);

  // 获取路由参数
  dynamic get arguments => Get.arguments;

  Widget buildWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return buildWidget(context);  // 使用Obx包裹，实现响应式更新
    });
    // return  buildWidget();
  }
}
