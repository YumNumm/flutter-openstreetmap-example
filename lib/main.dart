import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:test/mercator_projection.dart';

import 'custommap.dart';

late GeoJsonFeatureCollection shibuyaBuildings;
late GeoJsonFeatureCollection worldPolygons;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mapを読み込み
  final shibuyaBuildingsJson = await rootBundle.loadString("assets/japan.json");
  shibuyaBuildings = await featuresFromGeoJson(shibuyaBuildingsJson);
  final worldJson = await rootBundle.loadString("assets/world.json");
  worldPolygons = await featuresFromGeoJson(worldJson);

  runApp(
    MaterialApp(
      home: const HomePage(),
      theme: ThemeData.dark()
          .copyWith(useMaterial3: true, colorScheme: const ColorScheme.dark()),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Size screenSize;
  late Offset screenCenter;
  List<Path> _pointsBuildings = <Path>[];

  @override
  Widget build(BuildContext context) {
    // screenSizeを取得
    // TODO orientation変化時の処理
    screenSize = MediaQuery.of(context).size;
    screenCenter = screenSize.center(Offset.zero);

    // 建物データの緯度経度を画面描画用に加工
    for (final e in shibuyaBuildings.collection) {
      if (e.geometry.runtimeType == GeoJsonMultiPolygon) {
        final geometry = e.geometry as GeoJsonMultiPolygon;
        for (final polygon in geometry.polygons) {
          for (final geoSeries in polygon.geoSeries) {
            List<Offset> tmpPoints = <Offset>[];
            for (final geoPoint in geoSeries.geoPoints) {
              tmpPoints.add(MercatorProjection.latLonToPoint(geoPoint.point));
            }
            _pointsBuildings = List.from(_pointsBuildings)
              ..add(Path()..addPolygon(tmpPoints, true));
          }
        }
      } else if (e.geometry.runtimeType == GeoJsonPolygon) {
        final geometry = e.geometry as GeoJsonPolygon;
        for (final geoSeries in geometry.geoSeries) {
          List<Offset> tmpPoints = <Offset>[];
          for (final geoPoint in geoSeries.geoPoints) {
            tmpPoints.add(MercatorProjection.latLonToPoint(geoPoint.point));
          }
          _pointsBuildings = List.from(_pointsBuildings)
            ..add(Path()..addPolygon(tmpPoints, true));
        }
      }
    }

    /*// マップデータが既にOffsetに変換されているなら、dx,dyのみ加算する
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
    }*/
    final TransformationController transformationController =
        TransformationController();
    final globalViewerKey = GlobalKey();

    late AnimationController animationController;
    late Animation<Matrix4> mapAnimation;

    return Scaffold(
      appBar: AppBar(title: const Text("MapTest")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final viewer = globalViewerKey.currentState;
          var start = Matrix4.identity()
            ..translate(
              MercatorProjection.latLonToPoint(LatLng(34, 136)),
            );
          var end = Matrix4.identity()
            ..translate(
              MercatorProjection.latLonToPoint(LatLng(35, 135)),
            );
          animationController = AnimationController(
              duration: const Duration(seconds: 5), vsync: this);
          mapAnimation =
              Matrix4Tween(begin: start, end: end).animate(animationController);
          mapAnimation.addListener(() {
            setState(() {
              transformationController.value =
                  Matrix4.inverted(mapAnimation.value);
            });
          });
          animationController.forward();
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          onInteractionStart: (ScaleStartDetails scaleStartDetails) {
            log('Interaction Start - Focal point: ${scaleStartDetails.focalPoint}'
                ', Local focal point: ${scaleStartDetails.localFocalPoint}');
          },
          onInteractionEnd: (ScaleEndDetails scaleEndDetails) {
            log('Interaction End - Velocity: ${scaleEndDetails.velocity}');
          },
          onInteractionUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
            log('Interaction Update - Focal point: ${scaleUpdateDetails.focalPoint}'
                ', Local focal point: ${scaleUpdateDetails.localFocalPoint}'
                ', Scale: ${scaleUpdateDetails.scale}'
                ', Horizontal scale: ${scaleUpdateDetails.horizontalScale}'
                ', Vertical scale: ${scaleUpdateDetails.verticalScale}'
                ', Rotation: ${scaleUpdateDetails.rotation}');
          },
          key: globalViewerKey,
          minScale: 1,
          maxScale: 1000,
          //boundaryMargin: const EdgeInsets.all(double.infinity),
          transformationController: transformationController,
          constrained: false,
          panEnabled: true,
          scaleEnabled: true,

          child: CustomPaint(
            painter: CustomMap(
              screenSize: Size.infinite,
              pointsBuildings: _pointsBuildings,
            ),
            size: screenSize,
          ),

          //child: GestureDetector(
          //* onPanUpdateと同時に動かないのでコメントアウト
          //onScaleUpdate: (ScaleUpdateDetails details) {
          //  setState(() {
          //    _scale = details.scale;
          //  });
          //},
          //  onPanUpdate: (DragUpdateDetails details) {
          //    setState(() {
          //      _delta = _delta + details.delta;
          //    });
          //  },
          //  child: ,
        ),
      ),
    );
  }
}
