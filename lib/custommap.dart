import 'dart:developer';

import 'package:flutter/material.dart';

class CustomMap extends CustomPainter {
  Size screenSize;
  List<Path> pointsBuildings;
  final bgColor = const Color(0xFFF7F7F7);
  final borderColor = const Color(0xFFCBCBCB);
  final buildingColor = const Color(0xFFEFEFEF);
  double scale = 1.0;
  Offset delta = Offset.zero;

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
    ..color = const Color.fromARGB(255, 71, 22, 207)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.0;

  CustomMap({
    required this.delta,
    required this.scale,
    required this.screenSize,
    required this.pointsBuildings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Buildingsの描画開始
    final start = DateTime.now().millisecondsSinceEpoch;
    for (final point in pointsBuildings) {
      canvas.drawPath(point, paintBuilding);
    }
    final end = DateTime.now().millisecondsSinceEpoch;
    log("Draw Buildings: ${end - start}ms");
    // Buildings描画終了
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
