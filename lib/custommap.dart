import 'dart:developer';

import 'package:flutter/material.dart';

class CustomMap extends CustomPainter {
  Size screenSize;
  List<Path> pointsBuildings;
  double scale = 2.0;
  Offset delta = Offset.zero;

  bool isDrawed = false;

  /*final Paint paintRoads = Paint()
    ..color = const Color.fromARGB(255, 0, 0, 0)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3.0;
  final Paint paintBorder = Paint()
    ..color = const Color.fromARGB(255, 202, 63, 63)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;
  final Paint paintBuildingBorder = Paint()
    ..color = const Color.fromARGB(255, 213, 15, 15)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.0;*/

  final Paint paintBuilding = Paint()
    ..color = const Color.fromARGB(255, 17, 147, 0)
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;

  final Paint paintOutline = Paint()
    ..color = const Color.fromARGB(255, 218, 218, 218)
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.001;

  CustomMap({
    required this.screenSize,
    required this.pointsBuildings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.restore();
    canvas
      ..translate(delta.dx, delta.dy)
      ..scale(scale, scale);
    // Buildingsの描画開始
    final start = DateTime.now().millisecondsSinceEpoch;
    for (final point in pointsBuildings) {
      canvas.drawPath(point, paintBuilding);
      //..drawPath(point, paintOutline);
    }
    final end = DateTime.now().millisecondsSinceEpoch;
    log("Draw Buildings(Build): ${end - start}ms");
    // Buildings描画終了
    canvas.save();
    return;

    log("SAVE COUNT: ${canvas.getSaveCount()} $isDrawed");
    // 初回描画かどうかを判別
    if (canvas.getSaveCount() == 1) {
      isDrawed = true;
    } else {
      final start = DateTime.now().millisecondsSinceEpoch;
      canvas
        ..translate(delta.dx, delta.dy)
        ..scale(scale, scale);
      final end = DateTime.now().millisecondsSinceEpoch;
      log("Draw Buildings(Rebuild): ${end - start}ms");
    }
    canvas.save();
  }

  // 描画する点がスクリーン内に含まれるかどうか
  bool isInScreen(Offset first, Offset second) {
    first = first.scale(scale, scale);
    second = second.scale(scale, scale);
    if ((first.dx > -1 &&
            first.dy > -1 &&
            first.dx < screenSize.width &&
            first.dy < screenSize.height) ||
        (second.dx > -1 &&
            second.dy > -1 &&
            second.dx < screenSize.width &&
            second.dy < screenSize.height)) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRepaint(CustomMap oldDelegate) => true;
}
