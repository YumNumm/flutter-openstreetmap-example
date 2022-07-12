import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart' as latlong;

import 'custommap.dart';

late GeoJsonFeatureCollection shibuyaLines;
late GeoJsonFeatureCollection shibuyaBuildings;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mapを読み込み
  final shibuyaLinesJson =
      await rootBundle.loadString("assets/geo_shibuya_lines.geojson");
  shibuyaLines = await featuresFromGeoJson(shibuyaLinesJson);

  final shibuyaBuildingsJson =
      await rootBundle.loadString("assets/geo_shibuya_buildings.geojson");
  shibuyaBuildings = await featuresFromGeoJson(shibuyaBuildingsJson);

  runApp(
    const MaterialApp(home: HomePage()),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Size screenSize;
  late Offset screenCenter;
  List<Offset> _roadsPoints = <Offset>[];
  final List<Path> _buildingsPoints = <Path>[];
  List<Path> _pointsBuildings = <Path>[];

  final double _scale = 0.2;
  Offset _delta = Offset.zero;

  // 渋谷駅の緯度経度
  latlong.LatLng currentLocation = latlong.LatLng(35.6573151, 139.7024518);
  @override
  Widget build(BuildContext context) {
    // screenSizeを取得
    // TODO orientation変化時の処理
    screenSize = MediaQuery.of(context).size;
    screenCenter = screenSize.center(Offset.zero);
    var jsonDataBuildings;

    // 建物データの緯度経度を画面描画用に加工

    for (final e in shibuyaBuildings.collection) {
      final geometry = e.geometry as GeoJsonMultiPolygon;
      for (final polygon in geometry.polygons) {
        for (final geoSeries in polygon.geoSeries) {
          List<Offset> tmpPoints = <Offset>[];
          for (final geoPoint in geoSeries.geoPoints) {
            tmpPoints.add(
              Offset(
                  (geoPoint.longitude - currentLocation.longitude) * 300000.0 +
                      screenCenter.dx,
                  -(geoPoint.latitude - currentLocation.latitude) * 300000.0 +
                      screenCenter.dy),
            );
          }
          _pointsBuildings = List.from(_pointsBuildings)
            ..add(Path()..addPolygon(tmpPoints, true));
        }
      }
    }
    // マップデータが既にOffsetに変換されているなら、dx,dyのみ加算する
    if (_roadsPoints.isNotEmpty) {
      _roadsPoints = _roadsPoints.map((e) => e + _delta).toList();
    } else {
      // 道路データの緯度経度を画面描画用に加工
      for (final e in shibuyaLines.collection) {
        log(e.geometry.runtimeType.toString());
        if (e.geometry.runtimeType == GeoJsonLine) {
          final geometry = e.geometry as GeoJsonLine;
          for (final point in geometry.geoSerie!.geoPoints) {
            final latLng = point.toLatLng()!;
            // 初期位置（渋谷）を画面中央に配置
            Offset localPosition = Offset(
                (latLng.longitude - currentLocation.longitude) * 300000.0 +
                    screenCenter.dx,
                -(latLng.latitude - currentLocation.latitude) * 300000.0 +
                    screenCenter.dy);
            _roadsPoints = List.from(_roadsPoints)..add(localPosition);
          }
        }
      }
    }

    return Scaffold(
      body: Container(
          child: GestureDetector(
        //* onPanUpdateと同時に動かないのでコメントアウト
        //onScaleUpdate: (ScaleUpdateDetails details) {
        //  setState(() {
        //    _scale = details.scale;
        //  });
        //},
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            _delta = _delta + details.delta;
          });
        },
        child: CustomPaint(
          painter: CustomMap(
            scale: _scale,
            delta: _delta,
            pointsRoads: _roadsPoints,
            screenSize: screenSize,
            pointsBuildings: _pointsBuildings,
          ),
          size: Size.infinite,
        ), // CustomPaint
      ) // GestureDetector
          ), // Container
    ); // Scaffold
  }
}
