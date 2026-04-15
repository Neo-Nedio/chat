import 'package:chat_mobile/api/admin_api.dart';
import 'package:flutter/material.dart';

import '../custom_flutter_toast/index.dart';

class AdminDropMenu extends StatefulWidget {
  final Offset offset;
  final Color? backGroundColor;
  final bool isDisable;
  final String userId;
  final int duration;
  final VoidCallback? onActionCompleted;

  const AdminDropMenu({
    super.key,
    this.offset = const Offset(0, 30),
    this.backGroundColor = Colors.white,
    this.duration = 200,
    required this.isDisable,
    required this.userId,
    this.onActionCompleted,
  });

  @override
  State<AdminDropMenu> createState() => _AdminDropMenuDropMenuState();
}

class _AdminDropMenuDropMenuState extends State<AdminDropMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _adminApi = AdminApi();

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
          child: Text('重置密码'),
          onTap: () {
            _adminApi.restPassword(widget.userId).then((res){
              if(res['code'] == 0){
                CustomFlutterToast.showSuccessToast('他的新密码是${res['data']}');
              }else{
                CustomFlutterToast.showErrorToast('重置密码失败');
              }
            });
          },
        ),
        PopupMenuItem(
          child: Text(
              widget.isDisable
                  ? '解禁'
                  : '禁用'
          ),
          onTap: ()  async {
            final Map<String, dynamic> result;
            if(widget.isDisable){
              result = await _adminApi.unDisableUser(widget.userId);
            }else {
              result = await _adminApi.disableUser(widget.userId);
            }

            if(result['code'] == 0){
              CustomFlutterToast.showSuccessToast('修改成功');
              widget.onActionCompleted?.call();
            }else{
              CustomFlutterToast.showErrorToast(result['msg'] ?? '修改失败');
            }
          },
        ),
      ],
    );
  }
}
