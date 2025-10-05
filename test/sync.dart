import 'package:test/test.dart';
import 'package:coroutines/sync.dart';

void main() {
  group('Coroutine', () {
    test('can be run at least once', () {
      final executor = CoroutineExecutor();

      CoroutineValue<int> myCoroutine() sync* {
        int counter = 1;
        yield counter;
      }

      final int result = executor.runCoroutine(myCoroutine) ?? -1;
      expect(result, equals(1));
    });
  });

  test('can continue execution', () {
    final executor = CoroutineExecutor();

    CoroutineValue<int> myCoroutine() sync* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
      counter = 3;
      yield counter;
    }

    final int result1 = executor.runCoroutine(myCoroutine) ?? -1;
    expect(result1, equals(1));

    final int result2 = executor.runCoroutine(myCoroutine) ?? -1;
    expect(result2, equals(2));

    final int result3 = executor.runCoroutine(myCoroutine) ?? -1;
    expect(result3, equals(3));
  });

  test('can be stopped and restarted', () {
    final executor = CoroutineExecutor();

    CoroutineValue<int> myCoroutine() sync* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
      counter = 3;
      yield counter;
    }

    final int result1 = executor.runCoroutine(myCoroutine) ?? -1;
    expect(result1, equals(1));

    executor.stopCoroutine(myCoroutine);

    final int result2 = executor.runCoroutine(myCoroutine) ?? -1;
    expect(result2, equals(1));
  });

  test("addCoroutine doesn't start it", () {
    final executor = CoroutineExecutor();

    int counter = 0;
    CoroutineValue<int> myCoroutine() sync* {
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

    executor.runCoroutine(myCoroutine);
    expect(counter, equals(1));
  });

  test('runAllCoroutines continues all coroutines', () {
    final executor = CoroutineExecutor();

    int counterA = 0;
    CoroutineValue<int> myCoroutine1() sync* {
      counterA = 1;
      yield counterA;
      counterA = 2;
      yield counterA;
      counterA = 3;
      yield counterA;
    }

    int counterB = 0;
    CoroutineValue<int> myCoroutine2() sync* {
      counterB = 3;
      yield counterB;
      counterB = 4;
      yield counterB;
      counterB = 5;
      yield counterB;
    }

    executor.addCoroutine(myCoroutine1);
    executor.addCoroutine(myCoroutine2);

    executor.runAllCoroutines();
    expect(counterA, equals(1));
    expect(counterB, equals(3));

    executor.runAllCoroutines();
    expect(counterA, equals(2));
    expect(counterB, equals(4));
  });

  test('finished coroutine is removed from running coroutines', () {
    final executor = CoroutineExecutor();

    CoroutineValue<int> myCoroutine() sync* {
      int counter = 1;
      yield counter;
      counter = 2;
      yield counter;
    }

    expect(executor.countCoroutines, equals(0));

    executor.runCoroutine(myCoroutine); // value 1
    expect(executor.countCoroutines, equals(1));

    executor.runCoroutine(myCoroutine); // value 2
    executor.runCoroutine(myCoroutine); // value null, coroutine finished
    expect(executor.countCoroutines, equals(0));
  });
}
