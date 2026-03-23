
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_button/index.dart';
import '../../../components/custom_drop_menu/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class FriendInformationPage extends CustomWidget<FriendInformationLogic> {
  FriendInformationPage({super.key});

  ///头部
  List<Widget> _buildHeader(BuildContext context, bool innerBoxIsScrolled) => [

    /*SliverAppBar(
      flexibleSpace: FlexibleSpaceBar(...),  // 可伸缩内容
      expandedHeight: ...,                   // 展开高度
      pinned: true,                          // 滚动时固定
      actions: [...],                        // 右侧按钮
    )*/
      //SliverAppBar（可伸缩头部）
        SliverAppBar(
          //动态高度计算
          expandedHeight: Size.fromHeight(
              MediaQuery.of(context).size.width * 10.7 / 16.0 -  // ① 基于宽度的比例
                  MediaQueryData.fromView(
                      WidgetsBinding.instance.platformDispatcher.views.first
                  ).padding.top +                                    // ② 减去状态栏高度
                  30                                                 // ③ 加上额外偏移
          ).height,

          floating: false,      // 滚动时不会立即显示(向上滚动时，不会立即展开)
          pinned: true,         // 滚动时头部固定在顶部
          snap: false,          // 不会自动吸附
          elevation: 0.1,       // 极淡的阴影
          backgroundColor: const Color(0xFFfaf7ff),  // 浅紫色背景


          // 背景区域（头像+昵称）
          flexibleSpace: FlexibleSpaceBar(
            //标题,根据滑动距离动态展示名字(或备注)
            title: Obx(
              () => Opacity( // 滚动时动态改变透明度
                //滚动时，标题逐渐显示（透明度从 0 → 1）
                opacity: controller.opacity.value,
                child: Container(
                  color: Colors.transparent,
                  child: Text(
                    controller.friendRemark.isNotEmpty
                        ? controller.friendRemark   // 优先显示备注名
                        : controller.friendName,    // 无备注则显示昵称
                    style: const TextStyle(
                      color: Color(0xFF07000a),
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            centerTitle: true,//标题居中

            // 展开时的背景内容
            background: Row(
              children: [
                const SizedBox(width: 18.6),// 左边距
                //头像
                Container(
                  margin: const EdgeInsets.only(top: 30, right: 10),
                  child: CustomPortrait(
                    url: controller.friendPortrait,
                    size: 150,
                    radius: 75,
                  ),
                ),

                //右侧昵称和账号
                Container(
                  height: 150,
                  width: 150,
                  margin: const EdgeInsets.only(top: 30, left: 10),
                  // color: Colors.green,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //昵称
                        Text(
                          controller.friendName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            // color: Colors.white,
                            fontSize: 43.6, //// 超大昵称
                          ),
                        ),

                        const SizedBox(height: 26.3),

                        //账号
                        Text(
                          "账号：${controller.friendAccount}",
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF989898),
                            fontSize: 16.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),

          //右侧操作按钮
          actions: [
            IconButton(//关注按钮
              onPressed: controller.setConcern,
              icon: controller.isConcern
                  ? const Icon( // 粉色实心
                      Icons.favorite,
                      size: 32,
                      color: Color(0xFFf8a1d2),
                    )
                  : const Icon( // 灰色空心
                      Icons.favorite_border,
                      size: 32,
                      color: Color(0xFF989898),
                    ),
            ),
            //更多菜单
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 32),
              offset: const Offset(0, 46.3), // 向下偏移46.3px
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: const Color(0xFFFFFFFF),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                PopupMenuItem(
                  value: 1,
                  height: 40,
                  onTap: controller.deleteFriend,
                  child: const SizedBox(
                    width: 85,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon(Icons.person_add, size: 20),
                        SizedBox(width: 12),
                        Text('删除好友', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ];



  ///说一说图片浏览
  Widget _buildImageGrid(List<dynamic> imageUrls, String userId) =>
      GridView.builder(
        shrinkWrap: true,                        // ① 高度自适应
        physics: const NeverScrollableScrollPhysics(), // ② 禁用网格滚动
        padding: const EdgeInsets.symmetric(horizontal: 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,      // ③ 每行5列
          crossAxisSpacing: 0,    // ④ 列间距为0
          mainAxisSpacing: 0,     // ⑤ 行间距为0
          childAspectRatio: 1.0,  // ⑥ 宽高比1:1（正方形）
        ),
        itemCount: imageUrls.isNotEmpty ? 5 : 0, // ⑦ 固定显示5张
        itemBuilder: (context, index) =>
            _buildTalkImage(imageUrls[index], userId),
      );

  ///单个图片的异步加载和显示
  Widget _buildTalkImage(String imageStr, String userId) => Container(
        padding: const EdgeInsets.all(2.0),
        child: FutureBuilder<String>(
          future: controller.getImg(imageStr, userId), // 异步获取图片URL
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CachedNetworkImage(
                imageUrl: snapshot.data ?? '',
                fit: BoxFit.cover,
                //加载中
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffffffff),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/empty-bg.png'),
              );
            } else {
              //无数据/加载中
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xffffffff),
                    strokeWidth: 2,
                  ),
                ),
              );
            }
          },
        ),
      );

  ///下部身体
  Widget _buildBody(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFfaf7ff),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.3),

        child: SafeArea( // 避开系统UI
          child: SingleChildScrollView( // 可滚动内容
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,// 左对齐

              children: [
                // 深色分割线
                Container(
                  height: 1,
                  color: const Color(0xFF07000a),
                ),
                //性别 年龄 生日
                Row(
                  children: [
                    const SizedBox(width: 12.3),

                    //性别
                    Icon(
                        controller.friendGender == "男"
                            ? Icons.male
                            : Icons.female,
                        color: controller.friendGender == "男"
                            ? Colors.blue
                            : Colors.pink,
                        size: 25),
                    const SizedBox(width: 8.3),
                    Text(
                      controller.friendGender,
                      style: const TextStyle(
                        color: Color(0xFF07000a),
                        fontSize: 20,
                      ),
                    ),

                    //分割线
                    Container(
                      width: 1,
                      height: 20,
                      color: const Color(0xFF07000a),
                      margin: const EdgeInsets.symmetric(horizontal: 4.3),
                    ),

                    //年龄
                    Text(
                      "${controller.friendAge.toString()}岁",
                      style: const TextStyle(
                        color: Color(0xFF07000a),
                        fontSize: 20,
                      ),
                    ),

                    //分割线
                    Container(
                      width: 1,
                      height: 20,
                      color: const Color(0xFF07000a),
                      margin: const EdgeInsets.symmetric(horizontal: 4.3),
                    ),

                    //生日
                    Text(
                      controller.friendBirthday,
                      style: const TextStyle(
                        color: Color(0xFF07000a),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                //备注
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/edit.png',
                      height: 18.6,
                      width: 18.6,
                    ),
                    const SizedBox(width: 8.3),
                    const Text(
                      '备注：',
                      style:
                          TextStyle(color: Color(0xFF07000a), fontSize: 18.6),
                    ),
                    SizedBox( //备注区域
                        width: 100,
                          child: TextField(
                              controller: controller.commentController,
                              focusNode: controller.commentFocus,
                              onSubmitted: (v) =>
                                  controller.setRemark(v, context),
                              decoration: InputDecoration(
                                hintText: controller.friendRemark.isEmpty
                                    ? '设置备注'
                                    : controller.friendRemark,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                              ),
                            ),
                          )
                  ],
                ),

                //分组
                Row(
                  children: [
                    Image.asset(
                      'assets/images/group.png',
                      height: 18.6,
                      width: 18.6,
                    ),
                    const SizedBox(width: 8.3),
                    const Text(
                      '分组：',
                      style:
                          TextStyle(color: Color(0xFF07000a), fontSize: 18.6),
                    ),
                    controller.friendGroup.isNotEmpty
                        ? Container( // 有分组时显示下拉菜单
                            key: const Key('group_drop_menu'),
                            color: Colors.transparent,
                            width: 75.3,
                            alignment: Alignment.centerLeft,
                            child: DropMenuWidget( //下拉菜单
                              key: const Key('group_drop_menu_widget'),
                              backGroundColor: const Color(0xFFfbf4ff),  // 下拉菜单背景色（浅紫色）
                              selectTextStyle: const TextStyle(color: Color(0xFF07000a)),  // 选中项文字颜色（深色）
                              textColor: const Color(0xFF07000a),  // 触发器文字颜色
                              normalTextStyle: const TextStyle(     // 未选中项样式
                                color: Color(0xFF989898),           // 灰色文字
                                fontSize: 12.0,
                              ),
                              leading: const Padding(               // 触发器前面的组件（这里为空）
                                padding: EdgeInsets.all(0),
                                child: Text(''),
                              ),
                              data: controller.groupList,           // 分组数据列表
                              selectCallBack: controller.setGroup,   // 选中回调(设置新的分组)
                              offset: const Offset(0, 40),          // 下拉菜单偏移量（向下40px）
                              selectedValue: controller.friendGroup != "0"  // 当前选中的值
                                  ? controller.friendGroup
                                  : null,
                            ),
                          )
                        : Container(),
                  ],
                ),

                const SizedBox(height: 16.3),

                //好友签名
                Row(
                  children: [
                    Image.asset(
                      'assets/images/signature.png',
                      height: 18.6,
                      width: 18.6,
                    ),
                    const SizedBox(width: 8.3),
                    const Text(
                      '签名：',
                      style:
                          TextStyle(color: Color(0xFF07000a), fontSize: 18.6),
                    ),
                    Expanded(
                      child: Text(
                        controller.friendSignature,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF07000a),
                          fontSize: 16.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.3),

                //说一说
                Row(
                  children: [
                    Image.asset(
                      'assets/images/icon-circle-of-friends.png',
                      height: 18.6,
                      width: 18.6,
                      color: const Color(0xFF07000a),
                    ),
                    const SizedBox(width: 8.3),
                    const Text(
                      '说一说：',
                      style:
                          TextStyle(color: Color(0xFF07000a), fontSize: 18.6),
                    ),
                    Text(
                      controller.talkContent['text'],
                      style: const TextStyle(
                        color: Color(0xFF07000a),
                        fontSize: 16.3,
                      ),
                    ),
                  ],
                ),
                _buildImageGrid(
                    controller.talkContent['img'], controller.friendId),
                const SizedBox(height: 16.3),
              ],
            ),
          ),
        ),
      );

  @override
  Widget buildWidget(BuildContext context) => GestureDetector(
    //监听整个页面的点击事件,点击页面任意空白区域时，自动保存备注内容
        onTap: () =>
            controller.setRemark(controller.commentController.text, context),
        child: Scaffold(
          body: NestedScrollView(
            controller: controller.scrollController,  // 滚动控制器
            headerSliverBuilder: _buildHeader,        // 头部构建器
            body: _buildBody(context),                // 主体内容
          ),
          //悬浮按钮
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 19.3),
              CustomButton(
                text: '发消息',
                onTap: () {},
                width: 150,
              ),
              const SizedBox(width: 12.3),
              CustomButton(
                text: '视频聊天',
                onTap: () {},
                width: 150,
              ),
            ],
          ),
        ),
      );
}
