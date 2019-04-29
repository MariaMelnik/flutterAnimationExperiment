import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_data_set_mock.dart';
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
    Stream.periodic(Duration(seconds: 10)).listen(genData);
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
    GaugeRangeDecoration range3 = GaugeRangeDecoration(minVal: 0.6, maxVal: 60, color: Colors.yellow);
    GaugeRangeDecoration range2 = GaugeRangeDecoration(minVal: 60.0, maxVal: 74.0, color: Colors.green);
    GaugeRangeDecoration range1 = GaugeRangeDecoration(minVal: 74.0, maxVal: 82, color: Colors.red);
    GaugeRangeDecoration range4 = GaugeRangeDecoration(minVal: 82, maxVal: 160, color: Colors.blueGrey);


    GaugeDecoration gaugeDecoration = GaugeDecoration(
        arrowColor: Colors.black,
        arrowPaintingStyle: PaintingStyle.fill,
        arrowStartWidth: 8,
        baselineColor: Colors.blueGrey[50],
        tickColor: Colors.black.withOpacity(0.6),
        textStyle: TextStyle(
          color: Colors.black.withOpacity(0.6),
        ),
        rangesDecoration: [range1, range2, range3, range4],
        rangeWidth: 10.0,
        limitArrowHeight: 16.0,
        limitArrowWidth: 12.0,
//      backgroundColor: Colors.green[100]
    );



    GaugeDecoration darkGaugeDecoration = GaugeDecoration(
      arrowColor: Colors.grey,
      arrowPaintingStyle: PaintingStyle.fill,
      arrowStartWidth: 8,
      baselineColor: Colors.blueGrey[50],
      tickColor: Colors.black.withOpacity(0.6),
      textStyle: TextStyle(
        color: Colors.white.withOpacity(0.6),
      ),
      rangesDecoration: [range1, range2, range3, range4],
      rangeWidth: 10.0,
      limitArrowHeight: 16.0,
      limitArrowWidth: 12.0,
//      backgroundColor: Colors.green[100]
    );

    return Column(
      children: <Widget>[
        SizedBox(height: 10.0,),
        Expanded(
          flex: 1,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
              <Widget>[ SizedBox(width: 10.0,),
              Card(
//                color: Colors.green[100],
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: GaugeWidget(
                        gaugeType: GaugeType.valueDriverGauge,
                        minVal: 50.0,
                        maxVal: 90.0,
//            baselineVal: 75.6,
//            limitVal: 80.0,
                        gaugeDecoration: gaugeDecoration,
                        dataChangesStream: stream,
                      ),
                    ),
                    Text("AHU-1, 65%")
                  ],
                ),
              ),
              SizedBox(width: 10.0,),

              Card(
//                color: Colors.green[100],
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: GaugeWidget(
                        minVal: 50.0,
                        maxVal: 90.0,
//            baselineVal: 75.6,
//            limitVal: 80.0,
                        gaugeDecoration: gaugeDecoration,
                        dataChangesStream: stream,
                      ),
                    ),
                    Text("AHU-2, 35%")
                  ],
                ),
              ),
              SizedBox(width: 10.0,),

              GaugeWidget(
                minVal: 50.0,
                maxVal: 90.0,
//            baselineVal: 75.6,
//            limitVal: 80.0,
                gaugeDecoration: gaugeDecoration,
                dataChangesStream: stream,
              ),
              SizedBox(width: 10.0,),
              ],


          ),
        ),
        Expanded(
          flex: 1,
          child:    Card(
              color: Colors.black87.withOpacity(0.7),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: GaugeWidget(
                      minVal: 50.0,
                      maxVal: 90.0,
//            baselineVal: 75.6,
//            limitVal: 80.0,
                      gaugeDecoration: darkGaugeDecoration,
                      dataChangesStream: stream,
                    ),
                  ),
                  Text("AHU-2, 35%", style: TextStyle(color: Colors.white.withOpacity(0.9)),)
                ],
              ),),
        ),
        Expanded(
          flex: 3,
          child: StreamBuilder(
              stream: stream,
              builder: (_, snapshot) => Text("${snapshot.data}")
          ),
        )
      ],
    );
  }


  Widget _buildPie(){
    return Center(
      child: Container(
        height: double.infinity,
          color: Colors.blueGrey.withOpacity(0.03),
          child: RotatePie(buildingInfo: Data.data,)
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Animation", style: TextStyle(color: Colors.grey, letterSpacing: 1.2),),
      ),
//      body: _buildPie()
      body: _buildGauge()
    );
  }
}



