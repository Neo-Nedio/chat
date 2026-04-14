import 'package:flutter/material.dart';

class AdminDropMenu extends StatefulWidget {
  final Offset offset;
  final Color? backGroundColor;
  final int duration;

  const AdminDropMenu({
    super.key,
    this.offset = const Offset(0, 30),
    this.backGroundColor = Colors.white,
    this.duration = 200,
  });

  @override
  State<AdminDropMenu> createState() => _AdminDropMenuDropMenuState();
}

class _AdminDropMenuDropMenuState extends State<AdminDropMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _animation = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      offset: widget.offset,
      color: widget.backGroundColor,
      onOpened: () => _animationController.forward(),
      onCanceled: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 2.0 * 3.14,
            child: const Icon(Icons.arrow_drop_down),
          );
        },
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text('修改密码'),
          onTap: () {},
        ),
        PopupMenuItem(
          child: Text('禁用/解除禁用'),
          onTap: () {},
        ),
      ],
    );
  }
}
