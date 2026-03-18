import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../../components/custom_material_button/index.dart';
import '../login/index.dart';

final _userApi = UserApi();

//我的页面
class Mine extends StatefulWidget {
  const Mine({super.key});

  @override
  State<StatefulWidget> createState() => _MinePageState();
}

class _MinePageState extends State<Mine> {
  late dynamic currentUserInfo = {};

  @override
  void initState() {
    super.initState();
    _onGetCurrentUserInfo();
  }

  //获取用户信息
  void _onGetCurrentUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserInfo['name'] = prefs.getString('username');
      currentUserInfo['portrait'] = prefs.getString('portrait');
      currentUserInfo['account'] = prefs.getString('account');
    });
  }

  //退出登录
  void _handlerLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除所有本地数据
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,// 移除所有路由
    );
  }
/*
  ┌─────────────────────────────────────┐
  │  Gradient Container (渐变背景)       │
  │  ┌─────────────────────────────────┐ │
  │  │  Row                            │ │
  │  │  ┌─────┐  ┌───────────────────┐ │ │
  │  │  │     │  │ 用户名            │ │ │
  │  │  │ 头像 │  │ 账号：xxx        │ │ │
  │  │  │70x70│  └───────────────────┘ │ │
  │  │  └─────┘  ←──间距10──→  󰀃      │ │
  │  └─────────────────────────────────┘ │
  ├─────────────────────────────────────┤
  │  Transform.translate (上移30px)      │
  │  ┌─────────────────────────────────┐ │
  │  │  Column                         │ │
  │  │  ┌───────────────────────────┐  │ │
  │  │  │ 我的说说             ▶   │  │ │ ← 主要按钮 (高60)
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 系统通知             ▶   │  │ │
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 修改密码   󰀃  ▶           │  │ │ ← 次要按钮 (高50)
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 关于我们   󰀃  ▶           │  │ │
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 设置       󰀃  ▶           │  │ │
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 切换账号                   │  │ │ ← 最小按钮 (居中)
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 退出 (红色)                │  │ │
  │  │  └───────────────────────────┘  │ │
  │  └─────────────────────────────────┘ │
  └─────────────────────────────────────┘
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF), // 浅蓝色背景
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(  // 线性渐变
                colors: [Color(0xFFDFF4FF), Color(0xFFFFFFFF)],  // 浅蓝到白
                begin: Alignment.topLeft,      // 渐变起点：左上角
                end: Alignment.bottomRight,    // 渐变终点：右下角
              ),
              borderRadius: BorderRadius.only(  // 底部圆角
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            height: 200,  // 高度200像素

            padding: const EdgeInsets.symmetric(horizontal: 30),  // 左右内边距30
            child: Row(
              children: [
                //头像区域
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: CachedNetworkImage(
                      imageUrl: currentUserInfo['portrait'] ?? '', // 头像URL
                      fit: BoxFit.cover,
                      // 加载中的占位图
                      placeholder: (context, url) => Container(
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffffffff),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      // 加载失败的占位图
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child:
                            Image.asset('assets/images/default-portrait.jpeg'),
                      ),
                    ),
                  ),
                ),

                //分割
                const SizedBox(width: 10),

                // 文字信息区域
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 用户名（带特殊效果）
                          Stack(
                            alignment: Alignment.center,  // 子组件居中对齐
                            clipBehavior: Clip.none,      // 允许子组件超出边界
                            children: [
                              Positioned(
                                top: 13,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),  // 左右内边距5
                                    height: 15,  // 高度15像素
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(  // 线性渐变
                                        colors: [
                                          Color(0x1A4C9BFF),  // 透明蓝 (10%透明度)
                                          Color(0xE64C9BFF)   // 不透明蓝 (90%透明度)
                                        ],
                                        begin: Alignment.centerLeft,   // 从左开始
                                        end: Alignment.centerRight,    // 到右结束
                                      ),
                                      borderRadius: BorderRadius.circular(10),  // 圆角10
                                    ),
                                    //用完全透明的字体将特殊效果按文字数展开
                                    child: Opacity(
                                      opacity: 0,  // 完全透明
                                      child: Text(  // 透明文字
                                        currentUserInfo['name'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 实际显示的文字
                              Text(
                                currentUserInfo['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10), // 间距

                          //账号信息
                          Text(
                            '账号：${currentUserInfo['account'] ?? ''}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),

                      //右侧图标
                      const Icon(IconData(0xe615, fontFamily: 'IconFont'),
                          size: 45)
                    ],
                  ),
                ),
              ],
            ),
          ),
//Transform.translate 是 Flutter 中用于对子组件进行位置偏移的组件。它可以在不改变布局的情况下，让子组件相对于其原始位置移动。
          Transform.translate(
            offset: const Offset(0, -30), // 向上偏移30像素
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _primarySelectButton('我的说说', 'mine-talk.png', () {}),
                  const SizedBox(height: 2),
                  _primarySelectButton('系统通知', 'mine-notify.png', () {}),
                  const SizedBox(height: 30),
                  _minorSelectButton('修改密码', 'mine-password.png', () {}),
                  const SizedBox(height: 2),
                  _minorSelectButton('关于我们', 'mine-about.png', () {}),
                  const SizedBox(height: 2),
                  _minorSelectButton('设置', 'mine-set.png', () {}),
                  const SizedBox(height: 30),
                  _leastSelectButton('切换账号', () {}),
                  const SizedBox(height: 2),
                  _leastSelectButton(
                      '退出', color: const Color(0xfffff4c4c), _handlerLogout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //主要按钮
  Widget _primarySelectButton(String text, String iconStr, Function() onTap) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,  // 透明背景
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
          children: [
            Text(                                             // 左侧文字
              text,
              style: const TextStyle(fontSize: 16),
            ),
            Image.asset('assets/images/$iconStr', width: 40), // 右侧图片
          ],
        ),
      ),
    );
  }

  //次要按钮
  Widget _minorSelectButton(String text, String iconStr, Function() onTap) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左侧图标+文字
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/$iconStr', width: 20),
                const SizedBox(width: 1),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1),
                ),
              ],
            ),
            // 这个 Center 只是让它的 child 居中，而不是让它在 Row 中居中
            Center( // 右侧箭头图标
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  const IconData(0xe61f, fontFamily: 'IconFont'),
                  size: 18,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 最小按钮
  Widget _leastSelectButton(String text, Function() onTap, {Color? color}) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,// // 居中对齐
          children: [
            Text(
              text,
              style: TextStyle(
                  fontSize: 14, height: 1, color: color ?? Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
