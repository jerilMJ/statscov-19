class Stack<T> {
  Stack([this._stack]);

  List<T> _stack = [];

  bool get isEmpty => _stack.isEmpty;

  int get length => _stack.length;

  void push(T item) {
    _stack.add(item);
  }

  T pop() {
    return isEmpty ? null : _stack.removeLast();
  }

  T top() {
    return isEmpty ? null : _stack.last;
  }

  @override
  String toString() {
    return isEmpty ? 'EMPTY' : '$_stack <-- TOP';
  }
}
