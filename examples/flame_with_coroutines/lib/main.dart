import 'dart:math';

import 'package:coroutines/coroutines.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

final _r = Random();

void main() {
  runApp(const GameWidget.controlled(gameFactory: SquaresCoroutineGame.new));
}

class SquaresCoroutineGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await world.addAll([
      for (var i = 0; i < 10; i++) SquareCoroutine(),
    ]);
    await super.onLoad();
  }
}

class SquareCoroutine extends PositionComponent
    with
        CoroutineExecutor,
        TapCallbacks,
        HasGameReference<SquaresCoroutineGame> {
  final _paint = Paint()..color = _r.nextColor();

  SquareCoroutine()
    : super(
        size: Vector2.all(100),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final bounds = game.camera.viewport.size / 2;
    position = Vector2(
      _r.nextDoubleBetween(-bounds.x, bounds.x),
      _r.nextDoubleBetween(-bounds.y, bounds.y),
    );
  }

  CoroutineValue<bool> _changeColor(Color newColor) sync* {
    const steps = 60;
    final currentColor = _paint.color;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      _paint.color = Color.lerp(currentColor, newColor, t)!;
      yield true; // yield to allow the game loop to render the frame
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final newColor = _r.nextColor();
    addCoroutine(() => _changeColor(newColor));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    runAllCoroutines();
  }
}
