import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'drawer.dart';
import 'mood_page_fab.dart';

class MoodPage extends StatefulWidget {
  @override
  State<MoodPage> createState() {
    return MoodPageState();
  }
}

class MoodPageState extends State<MoodPage> {
  List<Mood> moods = [];
  int selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    Global.firestore
        .collection('moods')
        .where(('userId'), isEqualTo: Global.userId)
        .snapshots()
        .listen((snapshot) {
      List<Mood> updatedMoods = snapshot.documents.map((documentSnapshot) {
        return Mood(
          (documentSnapshot.data['dateTime'] as Timestamp).toDate(),
          documentSnapshot.data['level'],
        );
      }).toList();
      setState(() {
        moods = updatedMoods;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  AlertDialog prompt =
                      AlertDialog(title: Text('Delete all data?'), actions: [
                    FlatButton(
                      child: Text('Yes'),
                      onPressed: () {
                        deleteMoods();
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ]);
                  return prompt;
                },
              );
            },
          )
        ],
      ),
      drawer: BetterMoodDrawer(),
      body: Container(
        color: Color(0xFFFFFFFF),
        child: (() {
          switch (selectedChartIndex) {
            case 0:
              {
                return Column(children: [
                  Flexible(child: timeSeriesGraph()),
                  Flexible(child: lineGraph())
                ]);
              }
              break;

            case 1:
              {
                return barChart();
              }
              break;

            case 2:
              {
                return pieChart();
              }
              break;
          }
        })(),
      ),
      floatingActionButton: FancyFab((mood) {
        addMood(mood);
      }),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            title: Text('Line Graph'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            title: Text('Bar Chart'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            title: Text('Pie Chart'),
          ),
        ],
        currentIndex: selectedChartIndex,
        onTap: (index) {
          setState(() {
            selectedChartIndex = index;
          });
        },
      ),
    );
  }

  Widget barChart() {
    int mood1count = moods.where((mood) => mood.level == 1).length;
    int mood2count = moods.where((mood) => mood.level == 2).length;
    int mood3count = moods.where((mood) => mood.level == 3).length;
    int mood4count = moods.where((mood) => mood.level == 4).length;
    int mood5count = moods.where((mood) => mood.level == 5).length;
    List<int> moodCounts = [
      mood1count,
      mood2count,
      mood3count,
      mood4count,
      mood5count
    ];
    List<int> moodLevels = [1, 2, 3, 4, 5];
    List<charts.Series<int, String>> seriesList = [
      charts.Series<int, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (int level, _) => level.toString(),
        measureFn: (int level, _) => moodCounts[level - 1],
        data: moodLevels,
      )
    ];

    return charts.BarChart(
      seriesList,
      animate: false,
    );
  }

  Widget timeSeriesGraph() {
    List<charts.Series<Mood, DateTime>> seriesList = [
      charts.Series<Mood, DateTime>(
        id: 'Mood',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Mood mood, _) => mood.dateTime,
        measureFn: (Mood mood, _) => mood.level,
        data: moods,
      )
    ];

    return charts.TimeSeriesChart(seriesList,
        animate: false,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
                new charts.BasicNumericTickProviderSpec(zeroBound: false)));
  }

  Widget lineGraph() {
    List<charts.Series<Mood, int>> seriesList = [
      charts.Series<Mood, int>(
        id: 'Mood',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Mood mood, _) => moods.indexOf(mood) + 1,
        measureFn: (Mood mood, _) => mood.level,
        data: moods,
      )
    ];

    return charts.LineChart(
      seriesList,
      animate: false,
      domainAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false)),
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false)),
    );
  }

  Widget pieChart() {
    int mood1count = moods.where((mood) => mood.level == 1).length;
    int mood2count = moods.where((mood) => mood.level == 2).length;
    int mood3count = moods.where((mood) => mood.level == 3).length;
    int mood4count = moods.where((mood) => mood.level == 4).length;
    int mood5count = moods.where((mood) => mood.level == 5).length;
    List<int> moodCounts = [
      mood1count,
      mood2count,
      mood3count,
      mood4count,
      mood5count
    ];
    List<int> moodLevels = [1, 2, 3, 4, 5];
    List<charts.Series<int, int>> seriesList = [
      charts.Series<int, int>(
        id: 'Mood',
        colorFn: (level, value) {
          switch (level) {
            case 1:
              {
                return charts.MaterialPalette.red.shadeDefault;
              }
              break;
            case 2:
              {
                return charts.MaterialPalette.deepOrange.shadeDefault;
              }
              break;
            case 3:
              {
                return charts.MaterialPalette.yellow.shadeDefault;
              }
              break;
            case 4:
              {
                return charts.MaterialPalette.lime.shadeDefault;
              }
              break;
            case 5:
              {
                return charts.MaterialPalette.green.shadeDefault;
              }
              break;
          }
        },
        domainFn: (int level, _) => level,
        measureFn: (int level, _) => moodCounts[level - 1],
        data: moodLevels,
        labelAccessorFn: (int level, _) {
          return moodCounts[level - 1].toString();
        },
      )
    ];

    return charts.PieChart(
      seriesList,
      animate: false,
      defaultRenderer: new charts.ArcRendererConfig(
        arcRendererDecorators: [charts.ArcLabelDecorator()],
      ),
    );
  }

  void addMood(int level) async {
    String userId = await Global.user.getIdToken();
    Global.firestore.collection('moods').add({
      'userId': userId,
      'dateTime': DateTime.now(),
      'level': level,
    });
  }

  void deleteMoods() async {
    Global.firestore
        .collection('moods')
        .where('userId', isEqualTo: Global.userId)
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((doc) {
        doc.reference.delete();
      });
    });
  }
}

class Mood {
  final DateTime dateTime;
  final int level;

  Mood(this.dateTime, this.level);

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'level': level,
    };
  }
}
