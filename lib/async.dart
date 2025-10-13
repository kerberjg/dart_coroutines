library coroutines;

import 'dart:async';

typedef CoroutineAsyncValue<T> = Stream<T>;
typedef CoroutineAsync<T> = CoroutineAsyncValue<T> Function();
typedef CoroutineAsyncInstance<T> = StreamIterator<T>;

mixin class CoroutineExecutor {
  /// Map of running coroutines
  /// Key: coroutine hash
  /// Value: coroutine instance
  final Map<int, CoroutineAsyncInstance> _runningCoroutines = {};

  /// The count of running coroutines
  int get countCoroutines => _runningCoroutines.length;

  /// Adds a coroutine to the executor without starting it
  /// Does nothing if the coroutine is already running
  void addCoroutine<T>(CoroutineAsync<T> coroutine) {
    _getOrAddCoroutine(coroutine);
  }

  @pragma('vm:always-consider-inlining')
  CoroutineAsyncInstance<T> _getOrAddCoroutine<T>(CoroutineAsync<T> coroutine) {
    final int id = coroutine.hashCode;
    if (_runningCoroutines[id] == null) {
      final stream = coroutine();
      _runningCoroutines[id] = StreamIterator<T>(stream);
    }

    return _runningCoroutines[id]! as CoroutineAsyncInstance<T>;
  }

  /// Starts or continues a coroutine
  /// It starts or continues its execution depending on its current state
  /// If the coroutine is paused, it resumes execution from the last yield point
  Future<T?> runCoroutine<T>(CoroutineAsync<T> coroutine) {
    return _stepCoroutine(coroutine.hashCode, _getOrAddCoroutine(coroutine));
  }

  /// Continues all coroutines in this executor
  Future<void> runAllCoroutines() async {
    for (final id in _runningCoroutines.keys) {
      await _stepCoroutine(id, _runningCoroutines[id]!);
    }
  }

  /// Returns whether a coroutine is currently running
  ///
  bool isCoroutineRunning(CoroutineAsync coroutine) {
    final int id = coroutine.hashCode;
    return _runningCoroutines.containsKey(id);
  }

  @pragma('vm:always-consider-inlining')
  Future<T?> _stepCoroutine<T>(int id, CoroutineAsyncInstance<T> instance) async {
    final bool hasNext = await instance.moveNext();

    if (hasNext) {
      return instance.current;
    } else {
      // coroutine has finished execution
      await instance.cancel();
      _runningCoroutines.remove(id);
      return null;
    }
  }

  /// Stops a coroutine
  void stopCoroutine(CoroutineAsync coroutine) {
    final int id = coroutine.hashCode;
    _runningCoroutines.remove(id);
  }

  /// Stops all coroutines in this executor
  void stopAllCoroutines() {
    _runningCoroutines.clear();
  }
}
