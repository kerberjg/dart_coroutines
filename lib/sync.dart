library coroutines;

typedef CoroutineValue<T> = Iterable<T>;
typedef Coroutine<T> = CoroutineValue<T> Function();
typedef CoroutineInstance<T> = Iterator<T>;

mixin class CoroutineExecutor {
  /// Map of running coroutines
  /// Key: coroutine hash
  /// Value: coroutine instance
  final Map<int, CoroutineInstance> _runningCoroutines = {};

  /// The count of running coroutines
  int get countCoroutines => _runningCoroutines.length;

  /// Adds a coroutine to the executor without starting it
  /// Does nothing if the coroutine is already running
  void addCoroutine<T>(Coroutine<T> coroutine) {
    _getOrAddCoroutine<T>(coroutine);
  }

  @pragma('vm:always-consider-inlining')
  CoroutineInstance<T> _getOrAddCoroutine<T>(Coroutine<T> coroutine) {
    final int id = coroutine.hashCode;
    if (_runningCoroutines[id] == null) {
      _runningCoroutines[id] = coroutine().iterator;
    }

    return _runningCoroutines[id]! as CoroutineInstance<T>;
  }

  /// Starts or continues a coroutine
  /// It starts or continues its execution depending on its current state
  /// If the coroutine is paused, it resumes execution from the last yield point
  T? runCoroutine<T>(Coroutine<T> coroutine) {
    return _stepCoroutine(coroutine.hashCode, _getOrAddCoroutine(coroutine));
  }

  /// Continues all coroutines in this executor
  void runAllCoroutines() {
    for (final id in _runningCoroutines.keys) {
      _stepCoroutine(id, _runningCoroutines[id]!);
    }
  }

  /// Returns whether a coroutine is currently running
  ///
  bool isCoroutineRunning(Coroutine coroutine) {
    final int id = coroutine.hashCode;
    return _runningCoroutines.containsKey(id);
  }

  @pragma('vm:always-consider-inlining')
  T? _stepCoroutine<T>(int id, CoroutineInstance<T> instance) {
    final bool hasNext = instance.moveNext();

    if (hasNext) {
      return instance.current;
    } else {
      // coroutine has finished execution
      _runningCoroutines.remove(id);
      return null;
    }
  }

  /// Stops a coroutine
  void stopCoroutine(Coroutine coroutine) {
    final int id = coroutine.hashCode;
    _runningCoroutines.remove(id);
  }

  /// Stops all coroutines in this executor
  void stopAllCoroutines() {
    _runningCoroutines.clear();
  }
}
