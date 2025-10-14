# coroutines
Unity-style Coroutines for Flutter/Dart, implementing resumable functions.

<!-- Badges -->
[![pub package](https://img.shields.io/pub/v/coroutines.svg)](https://pub.dev/packages/coroutines)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](LICENSE)
[![build](https://github.com/kerberjg/dart_coroutines/actions/workflows/package.yaml/badge.svg)](https://github.com/kerberjg/dart_coroutines/actions/workflows/package.yaml)
[![examples](https://github.com/kerberjg/dart_coroutines/actions/workflows/examples.yaml/badge.svg)](https://github.com/kerberjg/dart_coroutines/actions/workflows/examples.yaml)
[![stars](https://img.shields.io/github/stars/kerberjg/dart_coroutines.svg)](https://github.com/kerberjg/dart_coroutines/stargazers)


# Features
- Lightweight and easy to use
- Supports both synchronous and asynchronous coroutines
- Can be easily integrated into existing Flutter/Dart applications

# Installation
Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  coroutines: ^0.1.0
```

# Examples

## With widgets

In this example, a StatefulWidget uses the CoroutineExecutor mixin to run a coroutine that updates every time
a button is pressed.

```dart
import 'package:flutter/material.dart';
import 'package:coroutines/coroutines.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with CoroutineExecutor {
  int _counter = 0;

  void _incrementCounter() {
    runCoroutine(_myCoroutine);
  }

  CoroutineValue<int> _myCoroutine() sync* {
    while (true) {
      yield _counter++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coroutine Example'),
      ),
      body: Center(
        child: Text('Counter: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Game objects

```dart

class JumpingCube extends GameObject with CoroutineExecutor {
  double jumpSpeed = 10;
  double fallSpeed = -5

  bool isOnGround() {
    // Check if the cube is on the ground
  }

  /// Started when a jump button is pressed, iterates every frame to continue the jump animation
  CoroutineValue<bool> _jumpCoroutine() sync* {
    double verticalSpeed = jumpSpeed;

    while(!isOnGround()) {
      verticalSpeed -= 0.25; // apply gravity
      verticalSpeed = verticalSpeed.clamp(fallSpeed, double.infinity); // clamp to terminal velocity

      position.y += verticalSpeed; // move the cube
      yield true;
    }

    return false; // end of jump
  }

  @override
  void onKeyPressed(KeyEvent event) {
    // "An A-press is an A-press, you can't say it's only a half" - well, TJ "Henry" Yoshi...
    if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyA) {
      addCoroutine(_jumpCoroutine);
    }
  }

  @override
  void update(double deltaTime) {
    runAllCoroutines();
  }
}