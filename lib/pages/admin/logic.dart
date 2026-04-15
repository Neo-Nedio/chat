import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../api/admin_api.dart';

class AdminUserManageLogic extends GetxController {
  final _adminApi = AdminApi();
  final searchController = TextEditingController();

  //tab栏
  List<String> tabs = ['全部', '在线', '离线'];
  int selectedIndex = 0;

  // 普通列表
  List<dynamic> userList = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool isLoadingMore = false;

  // 搜索列表
  List<dynamic> searchList = [];
  int _searchPage = 1;
  bool _searchHasMore = true;
  bool isSearchLoadingMore = false;

  //搜索关键词
  String _searchKeyword = '';
  bool get isSearching => _searchKeyword.isNotEmpty;

  //是否正在加载
  bool isLoading = false;

  //根据条件获得展示列表
  List<dynamic> get displayList => isSearching ? searchList : userList;
  //根据条件获取不同的 hasMore
  bool get hasMore => isSearching ? _searchHasMore : _hasMore;

  void init() {
    onGetUserList();
  }

  //切换tab
  void handlerTabTapped(int index) {
    selectedIndex = index;
    _searchKeyword = '';
    searchController.clear(); //清空输入框
    searchList = [];
    _searchPage = 1;
    _searchHasMore = true;
    _resetAndLoad();
  }

  // 重置分页并加载第一页
  void _resetAndLoad() {
    _currentPage = 1;
    _hasMore = true;
    userList = [];
    onGetUserList();
  }

  //根据tab栏获取当前寻找的在线状态
  String? get _onlineStatus {
    switch (selectedIndex) {
      case 1:
        return 'online';
      case 2:
        return 'offline';
      default:
        return null;
    }
  }


  // 加载用户列表（首页或下一页）
  void onGetUserList() {
    if (_currentPage == 1) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }
    update([const Key('admin')]);

    _adminApi.userPage(
            currentPage: _currentPage,
            onlineStatus: _onlineStatus)
        .then((res) {
      isLoading = false;
      isLoadingMore = false;
      if (res['code'] == 0) {
        final records = res['data']['records'] ?? [];
        final int total = res['data']['total'] ?? 0;
        if (_currentPage == 1) {
          userList = records;
        } else {
          userList.addAll(records);
        }
        _hasMore = userList.length < total;
      }
      update([const Key('admin')]);
    });
  }

  // 上拉加载更多（普通列表）
  void loadMore() {
    if (!_hasMore || isLoadingMore) return;
    _currentPage++;
    onGetUserList();
  }

  // 搜索（关键词变化时重置）
  void onSearch(String keyword) {
    _searchKeyword = keyword.trim();
    if (_searchKeyword.isEmpty) {
      searchList = [];
      _searchPage = 1;
      _searchHasMore = true;
      update([const Key('admin')]);
      return;
    }
    _searchPage = 1;
    _searchHasMore = true;
    searchList = [];
    _doSearch();
  }

  // 执行搜索 API 调用
  void _doSearch() {
    if (_searchPage == 1) {
      isLoading = true;
    } else {
      isSearchLoadingMore = true;
    }
    update([const Key('admin')]);

    _adminApi
        .userPage(
            currentPage: _searchPage,
            keyword: _searchKeyword,
            onlineStatus: _onlineStatus)
        .then((res) {
      isLoading = false;
      isSearchLoadingMore = false;
      if (res['code'] == 0) {
        final records = res['data']['records'] ?? [];
        final int total = res['data']['total'] ?? 0;
        if (_searchPage == 1) {
          searchList = records;
        } else {
          searchList.addAll(records);
        }
        _searchHasMore = searchList.length < total;
      }
      update([const Key('admin')]);
    });
  }

  // 上拉加载更多（搜索列表）
  void loadMoreSearch() {
    if (!_searchHasMore || isSearchLoadingMore) return;
    _searchPage++;
    _doSearch();
  }

  // 统一的加载更多入口
  void onLoadMore() {
    if (isSearching) {
      loadMoreSearch();
    } else {
      loadMore();
    }
  }

  // 下拉刷新
  void onRefresh() {
    if (isSearching) {
      _searchPage = 1;
      _searchHasMore = true;
      searchList = [];
      _doSearch();
    } else {
      _resetAndLoad();
    }
  }
}
