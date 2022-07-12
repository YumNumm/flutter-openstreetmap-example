import 'dart:developer';

import 'package:flutter/material.dart';

class CustomMap extends CustomPainter {
  Size screenSize;
  List<Offset> pointsRoads;
  List<Path> pointsBuildings;
  final bgColor = const Color(0xFFF7F7F7);
  final borderColor = const Color(0xFFCBCBCB);
  final buildingColor = const Color(0xFFEFEFEF);
  double scale = 1.0;
  Offset delta = Offset.zero;

  final Paint paintRoads = Paint()
    ..color = const Color.fromARGB(255, 0, 0, 0)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3.0;
  final Paint paintBorder = Paint()
    ..color = const Color.fromARGB(255, 202, 63, 63)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;

  final Paint paintBuilding = Paint()
    ..color = const Color.fromARGB(255, 71, 22, 207)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.0;

  final Paint paintBuildingBorder = Paint()
    ..color = const Color.fromARGB(255, 213, 15, 15)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.0;

  CustomMap({
    required this.delta,
    required this.scale,
    required this.pointsRoads,
    required this.screenSize,
    required this.pointsBuildings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    int n = 0;

    canvas.translate(delta.dx, delta.dy);
    canvas.scale(scale, scale);
    canvas.drawColor(bgColor, BlendMode.color);
    // Roads Start
    if (pointsRoads.isNotEmpty) {
      final roadPath = Path();
      var start = DateTime.now().millisecondsSinceEpoch;
      for (final point in pointsRoads) {
        if (n == 0) {
          roadPath.moveTo(point.dx, point.dy);
        } else {
          roadPath.lineTo(point.dx, point.dy);
        }
        n++;
      }
      //canvas.drawPath(roadPath, paintRoads);
      /*for (int i = 0; i < pointsRoads.length - 1; i++) {
        if (isInScreen(pointsRoads[i], pointsRoads[i + 1])) {
          canvas.drawLine(pointsRoads[i], pointsRoads[i + 1], paintBorder);
        }
      }*/
      var end = DateTime.now().millisecondsSinceEpoch;
      log("Draw Roads Border: ${end - start}ms");

      var start2 = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < pointsRoads.length - 1; i++) {
        if (isInScreen(pointsRoads[i], pointsRoads[i + 1])) {
          // canvas.drawLine(pointsRoads[i], pointsRoads[i + 1], paintRoads);
        }
      }
      var end2 = DateTime.now().millisecondsSinceEpoch;
      log("Draw Roads: ${end2 - start2}ms");
    }
    // Roads End
    final buildingPath = Path();
    for (final point in pointsBuildings) {
      canvas.drawPath(point, paintBuilding);
      n++;
    }
    // Buildings Start
    var start = DateTime.now().millisecondsSinceEpoch;

    var end = DateTime.now().millisecondsSinceEpoch;
    log("Draw Buildings: ${end - start}ms");

    // Buildings End
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
