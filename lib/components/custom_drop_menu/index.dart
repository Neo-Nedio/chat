import 'package:flutter/material.dart';

class DropMenuWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data; //数据
  final Function(String value) selectCallBack; //选中之后回调函数
  final String? selectedValue; //默认选中的值
  final Widget? leading; //前面的widget，一般是title
  final Widget trailing; //尾部widget，默认向下箭头
  final Color? textColor;
  final Offset offset; //下拉框向下偏移量--手动调整间距---防止下拉框遮盖住显示的widget
  final TextStyle normalTextStyle; //下拉框的文字样式
  final TextStyle selectTextStyle; //下拉框选中的文字样式
  final double maxHeight; //下拉框的最大高度
  final double maxWidth; //下拉框的最大宽度
  final Color? backGroundColor; //下拉框背景颜色
  final bool animation; //是否显示动画---尾部图片动画
  final int duration; //动画时长

  const DropMenuWidget({
    super.key,
    this.leading,                    // 前置组件，通常是标题文字
    required this.data,              // 下拉数据 [{"label":"选项1","value":"1"}]
    required this.selectCallBack,    // 选中后回调函数
    this.selectedValue,              // 默认选中的值
    this.trailing = const Icon(Icons.arrow_drop_down),  // 尾部图标
    this.textColor = Colors.white,   // 显示文字颜色
    this.offset = const Offset(0, 30),  // 下拉框偏移量
    this.normalTextStyle = const TextStyle( // 普通选项样式
      color: Colors.white,
      fontSize: 12.0,
    ),
    this.selectTextStyle = const TextStyle( // 选中选项样式
      color: Colors.red,
      fontSize: 12.0,
    ),
    this.maxHeight = 200.0,          // 下拉框最大高度
    this.maxWidth = 200.0,           // 下拉框最大宽度
    this.backGroundColor = const Color.fromRGBO(28, 34, 47, 1),  // 背景色
    this.animation = true,           // 是否启用动画
    this.duration = 200,             // 动画时长
  });

  @override
  State<DropMenuWidget> createState() => _DropMenuWidgetState();
}

class _DropMenuWidgetState extends State<DropMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;  // 动画控制器
  late Animation<double> _animation;              // 动画值（0→0.5）
  String _selectedLabel = '';                     // 当前显示的文本
  String _currentValue = '';                      // 当前选中的值

  // 是否展开下拉按钮
  bool _isExpand = false; // 是否展开

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedValue ?? ''; // 设置默认选中值


    //初始化动画控制器
    if (widget.animation) {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration),
      );
      _animation = Tween(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut, // 缓动曲线：慢-快-慢
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //切换展开状态
  void _toggleExpand() {
    setState(() {
      if (_isExpand) {
        _animationController.forward(); // 展开时正向播放
      } else {
        _animationController.reverse(); // 收起时反向播放
      }
    });
  }

  //根据传值处理显示的文字
  void _initLabel() {
    if (_currentValue.isNotEmpty) {
      // 如果已有选中值，查找对应的 label
      _selectedLabel = widget.data
          .firstWhere((item) => item['value'] == _currentValue)['label'];
    } else if (widget.data.isNotEmpty) {
      // 没值默认取第一个
      _selectedLabel = widget.data[0]['label'];
      _currentValue = widget.data[0]['value'];
    }
  }

  @override
  //动画只控制右侧图标
  Widget build(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────────────────┐
    │                    DropMenuWidget                           │
    ├─────────────────────────────────────────────────────────────┤
    │  ┌─────────────────────────────────────────────────────┐   │
    │  │              PopupMenuButton                        │   │
    │  │  ┌───────────────────────────────────────────────┐ │   │
    │  │  │              child (触发器)                    │ │   │
    │  │  │  ┌─────────────────────────────────────────┐  │ │   │
    │  │  │  │  Container (40px高)                     │  │ │   │
    │  │  │  │  ┌───────────────────────────────────┐  │  │ │   │
    │  │  │  │  │         FittedBox                 │  │  │ │   │
    │  │  │  │  │  ┌─────────────────────────────┐  │  │  │ │   │
    │  │  │  │  │  │         Row                 │  │  │  │ │   │
    │  │  │  │  │  │  ┌──────┬──────┬─────────┐  │  │  │  │ │   │
    │  │  │  │  │  │  │leading│ Text │trailing │  │  │  │  │ │   │
    │  │  │  │  │  │  │ (可选)│显示值│ 箭头图标│  │  │  │  │ │   │
    │  │  │  │  │  │  └──────┴──────┴─────────┘  │  │  │  │ │   │
    │  │  │  │  │  └─────────────────────────────┘  │  │  │ │   │
    │  │  │  │  └───────────────────────────────────┘  │  │ │   │
    │  │  │  └─────────────────────────────────────────┘  │ │   │
    │  │  └───────────────────────────────────────────────┘ │   │
    │  │                                                      │   │
    │  │  ┌───────────────────────────────────────────────┐ │   │
    │  │  │          itemBuilder (下拉菜单)               │ │   │
    │  │  │  ┌─────────────────────────────────────────┐  │ │   │
    │  │  │  │  PopupMenuItem 1 (选项1)               │  │ │   │
    │  │  │  ├─────────────────────────────────────────┤  │ │   │
    │  │  │  │  PopupMenuItem 2 (选项2) ← 当前选中     │  │ │   │
    │  │  │  ├─────────────────────────────────────────┤  │ │   │
    │  │  │  │  PopupMenuItem 3 (选项3)               │  │ │   │
    │  │  │  └─────────────────────────────────────────┘  │ │   │
    │  │  └───────────────────────────────────────────────┘ │   │
    │  └─────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│                    未展开状态                                    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  [🏠] 上海  ▼                                           │    │
│  │   ↑     ↑    ↑                                          │    │
│  │ leading text  trailing                                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  箭头方向: 向下 (▼)                                             │
│  动画值: 0                                                      │
└─────────────────────────────────────────────────────────────────┘

                              ↓ 用户点击

┌─────────────────────────────────────────────────────────────────┐
│                    展开状态                                      │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  [🏠] 上海  ▲                                           │    │
│  │   ↑     ↑    ↑                                          │    │
│  │ leading text  trailing                                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  北京                                                  │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  上海  ← 当前选中 (红色/高亮)                          │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  广州                                                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  箭头方向: 向上 (▲)                                             │
│  动画值: 0.5                                                    │
│  下拉框偏移: Offset(0, 30) 避免遮挡触发器                       │
└─────────────────────────────────────────────────────────────────┘*/

    // 每次重建都重新计算显示文本
    _initLabel();

    //菜单的弹出是 PopupMenuButton 的内置行为
    return PopupMenuButton(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,   // 最大高度
        maxWidth: widget.maxWidth,     // 最大宽度
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0), // 圆角
      ),
      // 向下偏移
      offset: widget.offset,   // 偏移量(用于控制下拉菜单相对于触发器（child）的位置偏移。)
      color: widget.backGroundColor,   // 背景色

      //打开回调
      onOpened: () {
        if (widget.animation) {
          setState(() {
            _isExpand = true;
            _toggleExpand();
          });
        }
      },
      //关闭回调
      onCanceled: () {
        if (widget.animation) {
          setState(() {
            _isExpand = false;
            _toggleExpand();
          });
        }
      },

      //触发器（显示区域）
      child: Container(
        alignment: Alignment.centerLeft,
        height: 40,
        child: FittedBox(
          //使用FittedBox是为了适配当字符串长度超过指定宽度的时候，会让字体自动缩小
          child: Row(
            children: [
              if (widget.leading != null) widget.leading!, // 前置组件
              // 显示文本
              Text(
                _selectedLabel,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 14.0,
                ),
              ),

              //有动画时根据动画显示
              if (widget.animation)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                /*动画值范围：0 → 0.5，映射到旋转角度：
                    0 → 0° (箭头向下 ▼)
                    0.5 → 180° (箭头向上 ▲)*/
                      angle: _animation.value * 2.0 * 3.14, // 180度对应的弧度值
                      child: widget.trailing,
                    );
                  },
                ),
              // 无动画时直接显示
              if (!widget.animation) widget.trailing,
            ],
          ),
        ),
      ),

      //菜单项构建
      itemBuilder: (context) {
        return widget.data.map((e) {
          return PopupMenuItem(
            child: Text(
              e['label'],
              style: e['value'] == _currentValue
                  ? widget.selectTextStyle   // 选中样式
                  : widget.normalTextStyle,  // 普通样式
            ),
            onTap: () {
              //点击后设置新的选中项
              setState(() {
                _currentValue = e['value'];
                widget.selectCallBack(e['value']);
              });
            },
          );
        }).toList();
      },
    );
  }
}
