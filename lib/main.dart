import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart.dart';
import 'package:flutter_gauge_test/expandedPieChart/rotate_pie.dart';
import 'dart:math';

import 'package:flutter_gauge_test/gauge/gauge.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  static StreamController<double> controller = StreamController.broadcast();
  Stream<double> stream = controller.stream;



  MyHomePage() {
//    Stream.periodic(Duration(seconds: 4)).listen(genData);
  }

  void genData(dynamic num){
    Random random = Random();
    double val = random.nextDouble();
    double newVal = 90 * val;
    if (newVal < 50) newVal = newVal + 50;
    print("newVal is: ${newVal.toStringAsFixed(2)}");
    controller.add(newVal);
  }


  Widget _buildGauge(){
    GaugeRangeDecoration range1 = GaugeRangeDecoration(minVal: 0.0, maxVal: 0.3, color: Colors.red);
//    GaugeRangeDecoration range2 = GaugeRangeDecoration(minVal: 0.3, maxVal: 0.6, color: Colors.green);
    GaugeRangeDecoration range3 = GaugeRangeDecoration(minVal: 0.6, maxVal: 60, color: Colors.yellow);


    GaugeDecoration gaugeDecoration = GaugeDecoration(
        arrowColor: Colors.grey,
        arrowPaintingStyle: PaintingStyle.fill,
        tickWidth: 3.0,
        tickColor: Colors.black.withOpacity(0.6),
        textStyle: TextStyle(
          color: Colors.black.withOpacity(0.6),
        ),
        rangesDecoration: [range3],
        rangeWidth: 60.0,
        limitArrowHeight: 16.0,
        limitArrowWidth: 12.0
    );

    return Column(
      children: <Widget>[
        Center(
          child: GaugeWidget(
            minVal: 50.0,
            maxVal: 90.0,
            baselineVal: 75.6,
            limitVal: 80.0,
            gaugeDecoration: gaugeDecoration,
            dataChangesStream: stream,
          ),
        ),
        StreamBuilder(
            stream: stream,
            builder: (_, snapshot) => Text("${snapshot.data}")
        )
      ],
    );
  }


  Widget _buildPie(){
    return Center(
      child: Container(
        height: double.infinity,
          color: Colors.blueGrey.withOpacity(0.3),
          child: RotatePie()
      ),
    );
  }

  void _onPieTap(){

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("try gauge"),
      ),
      body: _buildPie()
    );
  }
}



