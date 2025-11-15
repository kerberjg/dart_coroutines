import 'package:test/test.dart';
import 'package:coroutines/async.dart';

void main() {
  group('CoroutineAsync', () {
    test('can be run at least once', () async {
      final executor = CoroutineExecutor();

      CoroutineAsyncValue<int> myCoroutine() async* {
        int counter = 1;
        yield counter;
      }

      final int result = await executor.runCoroutine(myCoroutine) ?? -1;
      expect(result, equals(1));
    });
  });

  test('can continue execution', () async {
    final executor = CoroutineExecutor();

    CoroutineAsyncValue<int> myCoroutine() async* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
      counter = 3;
      yield counter;
    }

    final int result1 = await executor.runCoroutine(myCoroutine) ?? -1;
    expect(result1, equals(1));

    final int result2 = await executor.runCoroutine(myCoroutine) ?? -1;
    expect(result2, equals(2));

    final int result3 = await executor.runCoroutine(myCoroutine) ?? -1;
    expect(result3, equals(3));
  });

  test('can be stopped and restarted', () async {
    final executor = CoroutineExecutor();

    CoroutineAsyncValue<int> myCoroutine() async* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
      counter = 3;
      yield counter;
    }

    final int result1 = await executor.runCoroutine(myCoroutine) ?? -1;
    expect(result1, equals(1));

    executor.stopCoroutine(myCoroutine);

    final int result2 = await executor.runCoroutine(myCoroutine) ?? -1;
    expect(result2, equals(1));
  });

  test("addCoroutine doesn't start it", () async {
    final executor = CoroutineExecutor();

    int counter = 0;
    CoroutineAsyncValue<int> myCoroutine() async* {
      counter = 1;
      yield counter;
      counter = 2;
      yield counter;
      counter = 3;
      yield counter;
    }

    expect(counter, equals(0));

    executor.addCoroutine(myCoroutine);
    expect(counter, equals(0));

    await executor.runCoroutine(myCoroutine);
    expect(counter, equals(1));
  });

  test('runAllCoroutines continues all coroutines', () async {
    final executor = CoroutineExecutor();

    int counterA = 0;
    CoroutineAsyncValue<int> myCoroutine1() async* {
      counterA = 1;
      yield counterA;
      counterA = 2;
      yield counterA;
      counterA = 3;
      yield counterA;
    }

    int counterB = 0;
    CoroutineAsyncValue<int> myCoroutine2() async* {
      counterB = 3;
      yield counterB;
      counterB = 4;
      yield counterB;
      counterB = 5;
      yield counterB;
    }

    executor.addCoroutine(myCoroutine1);
    executor.addCoroutine(myCoroutine2);

    await executor.runAllCoroutines();
    expect(counterA, equals(1));
    expect(counterB, equals(3));

    await executor.runAllCoroutines();
    expect(counterA, equals(2));
    expect(counterB, equals(4));
  });

  test('finished coroutine is removed from running coroutines', () async {
    final executor = CoroutineExecutor();

    CoroutineAsyncValue<int> myCoroutine() async* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
    }

    expect(executor.countCoroutines, equals(0));

    await executor.runCoroutine(myCoroutine); // value 1
    expect(executor.countCoroutines, equals(1));

    await executor.runCoroutine(myCoroutine); // value 2
    await executor.runCoroutine(myCoroutine); // value null, coroutine finished
    expect(executor.countCoroutines, equals(0));
  });

  test('correctly reports whether a coroutine is running', () async {
    final executor = CoroutineExecutor();

    CoroutineAsyncValue<int> myCoroutine() async* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
    }

    expect(executor.isCoroutineRunning(myCoroutine), isFalse);

    await executor.runCoroutine(myCoroutine); // value 1
    expect(executor.isCoroutineRunning(myCoroutine), isTrue);

    await executor.runCoroutine(myCoroutine); // value 2
    expect(executor.isCoroutineRunning(myCoroutine), isTrue);

    await executor.runCoroutine(myCoroutine); // value null, coroutine finished
    expect(executor.isCoroutineRunning(myCoroutine), isFalse);
  });

  test('concurrent modifications do not cause exceptions', () async {
    final executor = CoroutineExecutor();

    final futures = <Future>[];

    futures.add((() async => executor.addCoroutine(() async* {}))());
    futures.add((() async => executor.runAllCoroutines())());

    await Future.wait(futures);
  });

  test("doesn't step the coroutine until await is used", () async {
    final executor = CoroutineExecutor();

    int counter = 0;
    CoroutineAsyncValue<int> myCoroutine() async* {
      counter = 1;
      yield counter;
      counter = 2;
      yield counter;
      counter = 3;
      yield counter;
    }

    expect(counter, equals(0));

    final future = executor.runCoroutine(myCoroutine);
    expect(counter, equals(0));

    await future;
    expect(counter, equals(1));
  });
}
