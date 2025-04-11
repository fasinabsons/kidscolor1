// utils/history_manager.dart
mixin HistoryManager<T> {
  List<Map<int, T>> _history = [];
  int _historyIndex = -1;

  void saveToHistory(T state) {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }
    _history.add({0: state});
    _historyIndex++;
  }

  T? undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      return _history[_historyIndex][0];
    }
    return null;
  }

  T? redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      return _history[_historyIndex][0];
    }
    return null;
  }

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
}