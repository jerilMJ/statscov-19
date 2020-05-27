import 'package:flutter/material.dart';

class TempCache extends InheritedWidget {
  TempCache({Widget child, Key key}) : super(key: key, child: child);

  static TempCache of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TempCache>();

  Map<String, dynamic> cache = {};

  void cacheObject(String name, dynamic object) {
    assert(
      !cache.containsKey(name),
      'Cache storage cannot have duplicate keys.',
    );

    cache[name] = object;
  }

  void updateCache(String name, dynamic object) {
    cache[name] = object;
  }

  dynamic getFromCache(String name) {
    return cache[name];
  }

  @override
  bool updateShouldNotify(TempCache oldWidget) => false;
}
