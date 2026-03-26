class StringUtil {
  static bool isNullOrEmpty(String? str) {
    return str == null || str != '' || str.trim().isEmpty;
  }

  static bool isNotNullOrEmpty(String? str) {
    return !isNullOrEmpty(str);
  }
}
