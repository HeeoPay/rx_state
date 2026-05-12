import 'dart:collection';
import 'package:flutter/foundation.dart';

typedef Rx<T> = RxValue<T>;

class RxTracker {
  static final List<void Function(Listenable)> _collectors = [];

  static T track<T>(void Function(Listenable) collector, T Function() fn) {
    _collectors.add(collector);
    try {
      return fn();
    } finally {
      _collectors.removeLast();
    }
  }

  static void report(Listenable listenable) {
    if (_collectors.isNotEmpty) {
      _collectors.last(listenable);
    }
  }
}

class RxValue<T> extends ValueNotifier<T> {
  RxValue(super.value);

  @override
  T get value {
    RxTracker.report(this);
    return super.value;
  }

  T call([T? newValue]) {
    if (newValue != null) {
      value = newValue;
    }
    return value;
  }

  void refresh() {
    notifyListeners();
  }

  void update(T Function(T current) fn) {
    value = fn(value);
  }

  @override
  String toString() => value.toString();
}

class RxString extends RxValue<String> {
  RxString(super.value);
}

class RxInt extends RxValue<int> {
  RxInt(super.value);
}

class RxDouble extends RxValue<double> {
  RxDouble(super.value);
}

class RxBool extends RxValue<bool> {
  RxBool(super.value);

  void toggle() => value = !value;
}

class RxList<T> extends ChangeNotifier
    with ListMixin<T>
    implements ValueListenable<List<T>> {
  final List<T> _list;

  RxList([Iterable<T>? initial]) : _list = List<T>.from(initial ?? <T>[]);

  @override
  List<T> get value {
    RxTracker.report(this);
    return List.unmodifiable(_list);
  }

  set value(List<T> newValue) {
    _list
      ..clear()
      ..addAll(newValue);
    notifyListeners();
  }

  @override
  int get length {
    RxTracker.report(this);
    return _list.length;
  }

  @override
  set length(int newLength) {
    _list.length = newLength;
    notifyListeners();
  }

  @override
  T operator [](int index) {
    RxTracker.report(this);
    return _list[index];
  }

  @override
  void operator []=(int index, T newValue) {
    _list[index] = newValue;
    notifyListeners();
  }

  @override
  void add(T element) {
    _list.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _list.addAll(iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? element) {
    final result = _list.remove(element);
    if (result) notifyListeners();
    return result;
  }

  @override
  T removeAt(int index) {
    final item = _list.removeAt(index);
    notifyListeners();
    return item;
  }

  @override
  void clear() {
    if (_list.isEmpty) return;
    _list.clear();
    notifyListeners();
  }

  void assignAll(Iterable<T> items) {
    _list
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void update(void Function(List<T> list) fn) {
    fn(_list);
    notifyListeners();
  }

  @override
  String toString() => value.toString();
}

class RxMap<K, V> extends ChangeNotifier
    with MapMixin<K, V>
    implements ValueListenable<Map<K, V>> {
  final Map<K, V> _map;

  RxMap([Map<K, V>? initial]) : _map = Map<K, V>.from(initial ?? const {});

  @override
  Map<K, V> get value {
    RxTracker.report(this);
    return Map.unmodifiable(_map);
  }

  set value(Map<K, V> newValue) {
    _map
      ..clear()
      ..addAll(newValue);
    notifyListeners();
  }

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    _map[key] = value;
    notifyListeners();
  }

  @override
  void clear() {
    if (_map.isEmpty) return;
    _map.clear();
    notifyListeners();
  }

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) {
    final hadKey = _map.containsKey(key);
    final removed = _map.remove(key);
    if (hadKey) notifyListeners();
    return removed;
  }

  void assignAll(Map<K, V> items) {
    _map
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void mutate(void Function(Map<K, V> map) fn) {
    fn(_map);
    notifyListeners();
  }

  @override
  String toString() => value.toString();
}

class RxSet<T> extends ChangeNotifier
    with SetMixin<T>
    implements ValueListenable<Set<T>> {
  final Set<T> _set;

  RxSet([Set<T>? initial]) : _set = Set<T>.from(initial ?? const {});

  @override
  Set<T> get value {
    RxTracker.report(this);
    return Set.unmodifiable(_set);
  }

  set value(Set<T> newValue) {
    _set
      ..clear()
      ..addAll(newValue);
    notifyListeners();
  }

  @override
  bool add(T value) {
    final added = _set.add(value);
    if (added) notifyListeners();
    return added;
  }

  @override
  bool contains(Object? element) => _set.contains(element);

  @override
  Iterator<T> get iterator => _set.iterator;

  @override
  int get length => _set.length;

  @override
  T? lookup(Object? element) => _set.lookup(element);

  @override
  Set<T> toSet() => Set<T>.from(_set);

  @override
  bool remove(Object? value) {
    final removed = _set.remove(value);
    if (removed) notifyListeners();
    return removed;
  }

  @override
  void clear() {
    if (_set.isEmpty) return;
    _set.clear();
    notifyListeners();
  }

  void assignAll(Iterable<T> items) {
    _set
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void update(void Function(Set<T> set) fn) {
    fn(_set);
    notifyListeners();
  }

  @override
  String toString() => value.toString();
}

extension RxIntExtension on int {
  RxInt get rx => RxInt(this);
}

extension RxDoubleExtension on double {
  RxDouble get rx => RxDouble(this);
}

extension RxBoolExtension on bool {
  RxBool get rx => RxBool(this);
}

extension RxStringExtension on String {
  RxString get rx => RxString(this);
}

extension RxListExtension<T> on List<T> {
  RxList<T> get rx => RxList<T>(this);
}

extension RxMapExtension<K, V> on Map<K, V> {
  RxMap<K, V> get rx => RxMap<K, V>(this);
}

extension RxSetExtension<T> on Set<T> {
  RxSet<T> get rx => RxSet<T>(this);
}
