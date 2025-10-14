import 'package:coroutines/sync.dart';

void main(List<String> arguments) {
  final executor = CoroutineExecutor();

  CoroutineValue<int> myCoroutine() sync* {
    int counter = 1;
    while (true) {
      yield counter;
      counter++;
    }
  }

  for (int i = 0; i < 5; i++) {
    final int result = executor.runCoroutine(myCoroutine) ?? -1;
    print('Coroutine yielded: $result');
  }
}
