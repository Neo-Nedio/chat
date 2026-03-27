import 'package:flutter/material.dart';

//音波动画组件
class CustomSoundIcon extends StatefulWidget {
  final bool isStart;      // 是否启动动画（播放中）
  final Color barColor;    // 竖条颜色
  final double width;      // 整体宽度
  final double height;     // 整体高度

  const CustomSoundIcon({
    super.key,
    this.isStart = false,
    this.barColor = Colors.black,
    this.width = 26,
    this.height = 16,
  });

  @override
  State<CustomSoundIcon> createState() => _SoundIconState();
}

class _SoundIconState extends State<CustomSoundIcon>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    //动画控制器
    _controllers = List.generate(5, (index) { //创建 5 个动画控制器，每个控制一个竖条
      return AnimationController(
        duration: const Duration(milliseconds: 600),  // 一个完整周期 600ms
        vsync: this,  // 绑定 Ticker，节省资源
      );
    });

    //动画定义
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.5).animate( //原始高度 × 1.0 到 原始高度 × 1.5 之间变化。
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut, // 缓入缓出曲线
        ),
      );
    }).toList();

    if (widget.isStart) {
      _startAnimation(); // 如果初始就是播放状态，启动动画
    }
  }

  @override
  void didUpdateWidget(CustomSoundIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStart != oldWidget.isStart) {
      if (widget.isStart) {
        _startAnimation();   // 变为播放 → 启动动画
      } else {
        _stopAnimation();    // 变为暂停 → 停止动画
      }
    }
  }

  void _startAnimation() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(
        // 1. 计算每个竖条的延迟时间
        Duration(
          milliseconds: i == 0 || i == 4
              ? 0        // 两边的立即启动
              : i == 1 || i == 3
              ? 250   // 第二、四个延迟 250ms
              : 500,  // 中间的延迟 500ms
        ),
        // 2. 延迟后启动动画
            () {
          //reverse: true	动画到达终点后反向播放，形成来回效果
          _controllers[i].repeat(reverse: true);  // 反复播放，来回变化
        },
      );
    }
  }

  //关闭动画
  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.stop();   // 停止动画
      controller.reset();  // 重置到初始值（1.0）
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,   // 默认 26
      height: widget.height, // 默认 16
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // 均匀分布
        //生成 5 个竖条
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _animations[index], // 监听这个动画
            builder: (context, child) {
              return Container(
                width: 2,    // 固定宽度 2px
                height: _getBarHeight(index) * _animations[index].value,  // 动态高度
                color: widget.barColor,
              );
            },
          );
        }),
      ),
    );
  }

  //竖条原始高度
  double _getBarHeight(int index) {
    switch (index) {
      case 0: case 4: return 4.0;   // 两边的竖条最矮
      case 1: case 3: return 10.0;  // 中间偏外的竖条中等
      case 2:       return 16.0;    // 中间的竖条最高
      default:
        return 4.0;
    }
  }
}
