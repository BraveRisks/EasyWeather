import 'dart:core';

extension ExtensionString on String {

  /// 將字串轉換為數字，如果無法轉型則賦予預設值
  int intIfNullOrEmpty({int to = 0}) {
    return this.isEmpty            ? to :
           int.parse(this) == null ? to : int.parse(this);
  }

  /// 將字串轉換為double
  double toDouble() {
    return this.isEmpty               ? 0.0 :
           double.parse(this) == null ? 0.0 : double.parse(this);
  }
}