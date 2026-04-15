import 'package:flutter/material.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_search_box/index.dart';
import '../../components/custom_user_card/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

class AdminUserManagePage extends CustomWidget<AdminUserManageLogic> {
  AdminUserManagePage({super.key});

  @override
  init(BuildContext context) {
    controller.init();
  }

  @override
  Widget buildWidget(BuildContext context) {
    //展示列表
    final displayList = controller.displayList;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      //标题
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarTitle('用户管理'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),
      //主题
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Column(
          children: [
            // 搜索框
            CustomSearchBox(
              isCentered: false,
              hintText: '搜索用户',
              textEditingController: controller.searchController,
              onChanged: (value) => controller.onSearch(value),
            ),

            const SizedBox(height: 5),

            // Tab 栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 子元素均匀分布
              children: List.generate(controller.tabs.length, (index) {
                return Expanded(  // 每个Tab等宽
                  child: GestureDetector(
                    onTap: () => controller.handlerTabTapped(index), //切换
                    child: AnimatedContainer(  // 容器动画
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(5),
                      margin: EdgeInsets.symmetric(
                        horizontal: //选中时左右留白4px
                            index == controller.selectedIndex ? 4.0 : 0.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide( //下划线
                            color: index == controller.selectedIndex
                                ? theme.primaryColor   // 选中→主题色下划线
                                : Colors.transparent,  // 未选中：透明（看不见）
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(  //文字样式动画
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: index == controller.selectedIndex
                                ? theme.primaryColor
                                : Colors.black,
                            fontSize: 16,
                          ),
                          child: Text(controller.tabs[index]),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),

            // 内容区域
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  //加载成功
                  : displayList.isEmpty
                      //无用户
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/empty-image.png',
                                width: 100,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                controller.isSearching
                                    ? '未找到匹配用户~'
                                    : '暂无用户数据~',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        )
                        //有用户
                      : RefreshIndicator( //下拉刷新
                          onRefresh: () async {
                            controller.onRefresh();
                            return Future.delayed(
                                const Duration(milliseconds: 700));
                          },
                          color: theme.primaryColor,
                          child: NotificationListener<ScrollNotification>( //滚动监听
                            onNotification: (scroll) { //加载更多
                              if (scroll.metrics.pixels >=
                                      scroll.metrics.maxScrollExtent - 100 &&
                                  controller.hasMore) {
                                controller.onLoadMore();
                              }
                              return false;
                            },
                            //主体内容
                            child: GridView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.68,
                              ),
                              // 额外一项用于底部状态指示
                              itemCount: displayList.length + 1,
                              itemBuilder: (context, index) {
                                if (index >= displayList.length) {
                                  if (controller.hasMore) {
                                    //加载中
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    );
                                  }
                                  //没有更多
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        '没有更多了~',
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12),
                                      ),
                                    ),
                                  );
                                }
                                //用户卡片
                                return CustomUserCard(
                                    user: displayList[index],
                                    onActionCompleted: () => controller.onRefresh(), //刷新
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
