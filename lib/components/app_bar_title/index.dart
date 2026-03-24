import 'package:flutter/cupertino.dart';

//标题文本封装
class AppBarTitle extends StatelessWidget {
  final String title;

  const AppBarTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 20));
  }
}
