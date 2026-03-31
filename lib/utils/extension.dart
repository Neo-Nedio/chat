import 'package:flutter/foundation.dart';

//为 List 类型添加了四个实用方法，专门用于操作包含 Map<String, dynamic> 元素的列表。
/*
UsersListExtension	扩展名称
<E extends Map<String, dynamic>>	泛型约束：列表元素必须是 Map<String, dynamic> 类型
on List	为 List 类型添加方法
*/
extension UsersListExtension<E extends Map<String, dynamic>> on List {
  // 判断是否已包含某个好友
  bool include(Map value) {
    for (E e in this) {
      if (e['friendId'] == value['friendId']) return true;
    }
    return false;
  }

  //根据 friendId 删除好友
  bool delete(Map value) {
    for (E e in this) {
      if (e['friendId'] == value['friendId']) {
        return remove(e);
      }
    }
    return false;
  }

  //深拷贝列表
  List copy({List? list}) {
    List sourceList = list ?? this; // 若 list 为空，将本身设为当前对象
    if (sourceList.isEmpty) return []; // 若源列表为空，返回空列表

    List copyList = []; // 创建一个新的列表用于存放复制的元素
    try {
      for (var item in sourceList) {
        if (item is Map) {
          Map<String, dynamic> mapItem = Map.from(item); // 浅拷贝 Map
          copyList.add(mapItem);
        } else if (item is List) {
          copyList.add(item.copy()); // 递归拷贝嵌套列表
        } else {
          copyList.add(item);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('复制列表时发生错误: $e');
      } // 错误处理，输出错误信息
    }
    return copyList; // 返回复制后的列表
  }

  //替换元素
  List replace({dynamic oldValue, dynamic newValue, List? list}) {
    List sourceList = list ?? copy(); //copy是上面的深拷贝列表方法
    oldValue ??= newValue; //如果 oldValue 为 null，则将其赋值为 newValue
    // 如果源列表为空，直接返回空列表
    if (sourceList.isEmpty) return [];

    try {
      // 遍历列表并进行替换
      for (var i = 0; i < sourceList.length; i++) {
        if (sourceList[i]['id'] == oldValue['id']) {
          sourceList[i] = newValue;
          break; // 找到并替换后退出循环
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('替换值时发生错误: $e'); // 输出错误信息
      }
    }

    return sourceList; // 返回处理后的列表
  }
}
