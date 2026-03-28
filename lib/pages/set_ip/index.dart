import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_text_button/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../utils/getx_config/GlobalData.dart';

class SetIpPage extends StatefulWidget {
  const SetIpPage({super.key});

  @override
  State<SetIpPage> createState() => _SetIpPageState();
}

class _SetIpPageState extends State<SetIpPage> {

  final TextEditingController controller = TextEditingController();

  final globalData = GetInstance().find<GlobalData>();

  Future<void> setIp() async{
    SharedPreferences prefs =  await SharedPreferences.getInstance();

    prefs.setString('baseIp', controller.text);
    globalData.baseIp = controller.text;

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const AppBarTitle('设置访问ip'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          //右上角按钮
          actions: [
            CustomTextButton('完成',
                onTap: setIp,
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                fontSize: 14),
          ]),

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CustomTextField(
              labelText: "设置ip",
              controller: controller,
              hintText: "请输入访问的ip~",
            ),
          ],
        ),
      ),
    );
  }
}


