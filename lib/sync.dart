library coroutines;

typedef CoroutineValue<T> = Iterable<T>;
typedef Coroutine<T> = CoroutineValue<T> Function();

mixin class CoroutineExecutor {
  /// Map of running coroutines
  /// Key: coroutine hash
  /// Value: coroutine instance
  final Map<int, Iterator> _runningCoroutines = {};

  /// Adds a coroutine to the executor without starting it
  /// Does nothing if the coroutine is already running
  void addCoroutine(Coroutine coroutine) {
    _getOrAddCoroutine(coroutine);
  }

  @pragma('vm:always-consider-inlining')
  Iterator<T> _getOrAddCoroutine<T>(Coroutine<T> coroutine) {
    final int id = coroutine.hashCode;
    if (_runningCoroutines[id] == null) {
      _runningCoroutines[id] = coroutine().iterator;
    }

    return _runningCoroutines[id]! as Iterator<T>;
  }

  /// Starts or continues a coroutine
  /// It starts or continues its execution depending on its current state
  /// If the coroutine is paused, it resumes execution from the last yield point
  T? runCoroutine<T>(Coroutine<T> coroutine) {
    final Iterator<T> instance = _getOrAddCoroutine(coroutine);
    return _stepCoroutine(instance);
  }

  /// Continues all coroutines in this executor
  void runAllCoroutines() {
    for (final instance in _runningCoroutines.values) {
      _stepCoroutine(instance);
    }
  }

  @pragma('vm:always-consider-inlining')
  T? _stepCoroutine<T>(Iterator<T> instance) {
    final bool hasNext = instance.moveNext();

    if (hasNext) {
      return instance.current;
    } else {
      // coroutine has finished execution
      _runningCoroutines.remove(instance.hashCode);
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

  /// The count of running coroutines
  int get countCoroutines => _runningCoroutines.length;
}
