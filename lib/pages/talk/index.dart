import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/talk_api.dart';
import '../../api/user_api.dart';
import '../../components/custom_text_button/index.dart';
import '../../utils/date.dart';


final _talkApi = TalkApi();
final _userApi = UserApi();

class Talk extends StatefulWidget {
  const Talk({super.key});

  @override
  State<StatefulWidget> createState() => _TalkPageState();
}

class _TalkPageState extends State<Talk> {
  final List<dynamic> _talkList = [];  // 说说列表数据
  int _index = 0;                       // 分页索引
  bool _hasMore = true;                  // 是否还有更多数据
  bool _isLoading = false;               // 是否正在加载
  final ScrollController _scrollController = ScrollController(); // 滚动控制器

  @override
  void initState() {
    super.initState();
    _onTalkList();           // 首次加载数据
    _scrollController.addListener(_scrollListener); // 添加滚动监听
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //监听器
  void _scrollListener() {
    // 当滚动到底部时
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _onTalkList();  // 加载更多数据
    }
  }

  void _onTalkList() {
    if (!_hasMore || _isLoading) return;  // 没有更多或正在加载时返回

    setState(() {
      _isLoading = true;  // 显示加载状态
    });

    _talkApi.list(_index, 10).then((res) {  // 每页10条
      if (res['code'] == 0) {
        final List<dynamic> newTalks = res['data'];

        setState(() {
          if (newTalks.isEmpty) {
            _hasMore = false;  // 没有更多数据
          } else {
            _talkList.addAll(newTalks);  // 追加新数据
            _index += newTalks.length;   // 更新索引
          }
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    }).catchError((_) {
      setState(() { _isLoading = false; });  // 错误处理
    });
  }

  //下拉刷新
  Future<void> _refreshData() async {
    setState(() {
      _talkList.clear();  // 清空列表
      _index = 0;         // 重置索引
      _hasMore = true;    // 重置更多标志
    });
    _onTalkList();        // 重新加载
  }

  // 获取图片URL
  Future<String> _onGetImg(String fileName, String userId) async {
    dynamic res = await _userApi.getImg(fileName, userId);
    if (res['code'] == 0) {
      return res['data'];  // 返回图片URL
    }
    return '';  // 失败返回空字符串
  }

  @override
  Widget build(BuildContext context) {
  /*
    ┌─────────────────────────────────────┐
    │  ← 说说                    发表 ▶  │ ← AppBar
    ├─────────────────────────────────────┤
    │  ┌─────────────────────────────────┐ │
    │  │  ┌─────┐ 张三          10:30   │ │
    │  │  └─────┘                         │ │
    │  │  今天天气真好，出来玩啊~           │ │
    │  │  ┌───┬───┬───┐                  │ │
    │  │  │🖼️ │🖼️ │🖼️ │                  │ │
    │  │  ├───┼───┼───┤                  │ │
    │  │  │🖼️ │   │   │                  │ │
    │  │  └───┴───┴───┘                  │ │
    │  │  点赞(5) 评论(3)        删除    │ │
    │  │  查看更多内容 >                  │ │
    │  └─────────────────────────────────┘ │
    │  ┌─────────────────────────────────┐ │
    │  │  ┌─────┐ 李四          09:15   │ │
    │  │  └─────┘                         │ │
    │  │  分享一张照片                     │ │
    │  │  ┌───┐                           │ │
    │  │  │🖼️ │                           │ │
    │  │  └───┘                           │ │
    │  │  点赞(2) 评论(1)        删除    │ │
    │  │  查看更多内容 >                  │ │
    │  └─────────────────────────────────┘ │
    │                                      │
    │          没有更多内容了~              │ ← 底部footer
    └─────────────────────────────────────┘*/
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),// 浅蓝色背景
      appBar: AppBar(
          centerTitle: true,
          title: const Text('说说'),
          backgroundColor: const Color(0xFFF9FBFF),
          actions: [
            TextButton(
              onPressed: () {},
              child: CustomTextButton('发表', onTap: () {}, fontSize: 14),
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //刷新组件
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _talkList.length + 1, // +1 用于底部footer
            itemBuilder: (context, index) {
              if (index < _talkList.length) {
                return _buildTalkItem(_talkList[index]); // 说说项
              } else {
                return _buildFooter(); // 底部加载更多
              }
            },
          ),
        ),
      ),
    );
  }

  //底部Footer（加载更多/没有更多）
  Widget _buildFooter() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            //滚动圆圈
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Color(0xFF4C9BFF),
            ),
          ),
        ),
      );
    } else if (!_hasMore) {
      // 没有更多数据
      return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Center(
          child: Text(
            '没有更多内容了~',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 说说项构建
  Widget _buildTalkItem(dynamic talk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),  // 底部间距
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //用户信息
                  Row(
                    children: [
                      // 头像部分
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: talk['portrait'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          // 加载中显示进度圈
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xffffffff),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          // 加载失败显示默认头像
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Image.asset(
                                'assets/images/default-portrait.jpeg'),
                          ),
                        ),
                      ),

                      // 头像和文字的间距
                      const SizedBox(width: 10),

                      // 用户信息文字部分
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
                        children: [
                          Text(
                            talk['remark'] ?? talk['name'], // 优先显示备注，没有则显示姓名
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(height: 2), // 姓名和时间的小间距
                          Text(
                            DateUtil.formatTime(talk['time']),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[800]),
                          )
                        ],
                      ),
                    ],
                  ),

                  //用户信息与内容区域的间隔
                  const SizedBox(height: 10),

                  //内容区域
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(    // 上边框
                            color: Colors.grey[100]!,
                            width: 1.0
                        ),
                        bottom: BorderSide( // 下边框
                            color: Colors.grey[100]!,
                            width: 1.0
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 文本内容
                        Text(
                          talk['content']['text'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        // 图片网格
                        _buildImageGrid(
                            //img不是url,而是文件名字
                            talk['content']['img'] ?? [], talk['userId']),
                      ],
                    ),
                  ),

                  //内容区域与底部区域的间隔
                  const SizedBox(height: 5),

                  //底部统计行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("点赞（${talk['likeNum'] ?? 0}）",
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text("评论（${talk['commentNum'] ?? 0}）",
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      CustomTextButton('删除', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 5),
                  CustomTextButton('查看更多内容', onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 图片网格
  Widget _buildImageGrid(List<dynamic> imageUrls, String userId) {
    return GridView.builder(
      shrinkWrap: true,  // 根据内容收缩高度
      physics: const NeverScrollableScrollPhysics(), // 禁止网格自身滚动
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,      // 每行3列
        crossAxisSpacing: 0,    // 列间距0
        mainAxisSpacing: 0,     // 行间距0
        childAspectRatio: 1.0,  // 宽高比1:1
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildTalkImage(imageUrls[index], userId);
      },
    );
  }

  // 单个图片
  Widget _buildTalkImage(String imageStr, String userId) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: FutureBuilder<String>(
        future: _onGetImg(imageStr, userId),  // 异步获取图片URL
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CachedNetworkImage(// 显示图片
              imageUrl: snapshot.data ?? '',
              fit: BoxFit.cover,
              //加载图片
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xffffffff),
                    strokeWidth: 2,
                  ),
                ),
              ),
              //失败图片
              errorWidget: (context, url, error) => Container(
                child: Image.asset('assets/images/empty-bg.png'),
              ),
            );
          } else {
            // 加载中
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
  }
}
