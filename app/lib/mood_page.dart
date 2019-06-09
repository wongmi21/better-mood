import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'drawer.dart';
import 'fab_bottom_app_bar.dart';
import 'fab_with_icons.dart';
import 'globals.dart';
import 'layout.dart';

class MoodPage extends StatefulWidget {
  @override
  State<MoodPage> createState() {
    return MoodPageState();
  }
}

class MoodPageState extends State<MoodPage> {
  List<Mood> moods = [];
  String _lastSelected = 'TAB: 0';
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Global.firestore
        .collection('moods')
        .where('userId', isEqualTo: Global.userId)
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
          switch (_currentTabIndex) {
            case 0:
              return lineGraph();
            case 1:
              return timeSeriesGraph();
            case 2:
              return barChart();
            case 3:
              return pieChart();
          }
        })(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: FABBottomAppBar(
        color: Colors.grey,
        selectedColor: Theme.of(context).primaryColor,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.show_chart, text: 'Line'),
          FABBottomAppBarItem(iconData: Icons.show_chart, text: 'Time'),
          FABBottomAppBarItem(iconData: Icons.insert_chart, text: 'Bar'),
          FABBottomAppBarItem(iconData: Icons.pie_chart, text: 'Pie'),
        ],
      ),
    );
  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      _currentTabIndex = index;
    });
  }

  void _selectedFab(int index) {
    addMood(8 - index);
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

  Widget _buildFab(BuildContext context) {
    final icons = [
      Icon(Icons.sentiment_very_satisfied,
          color: Theme.of(context).primaryColor),
      Icon(Icons.mood, color: Theme.of(context).primaryColor),
      Icon(Icons.sentiment_satisfied, color: Theme.of(context).primaryColor),
      ImageIcon(AssetImage('assets/mood_satisfied.png'),
          color: Theme.of(context).accentColor),
      Icon(Icons.sentiment_neutral, color: Theme.of(context).primaryColor),
      ImageIcon(AssetImage('assets/mood_dissatisfied.png'),
          color: Theme.of(context).primaryColor),
      Icon(Icons.sentiment_dissatisfied, color: Theme.of(context).primaryColor),
      Icon(Icons.mood_bad, color: Theme.of(context).primaryColor),
      Icon(Icons.sentiment_very_dissatisfied,
          color: Theme.of(context).primaryColor),
    ];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - icons.length * 35.0),
          child: FabWithIcons(
            icons: icons,
            onIconTapped: _selectedFab,
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () {},
        child: ImageIcon(AssetImage('assets/happy_sad_icon.png')),
        elevation: 2.0,
      ),
    );
  }

  Widget barChart() {
    int mood0count = moods.where((mood) => mood.level == 0).length;
    int mood1count = moods.where((mood) => mood.level == 1).length;
    int mood2count = moods.where((mood) => mood.level == 2).length;
    int mood3count = moods.where((mood) => mood.level == 3).length;
    int mood4count = moods.where((mood) => mood.level == 4).length;
    int mood5count = moods.where((mood) => mood.level == 5).length;
    int mood6count = moods.where((mood) => mood.level == 6).length;
    int mood7count = moods.where((mood) => mood.level == 7).length;
    int mood8count = moods.where((mood) => mood.level == 8).length;
    List<int> moodCounts = [
      mood0count,
      mood1count,
      mood2count,
      mood3count,
      mood4count,
      mood5count,
      mood6count,
      mood7count,
      mood8count,
    ];
    List<int> moodLevels = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    List<charts.Series<int, String>> seriesList = [
      charts.Series<int, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (int level, _) => level.toString(),
        measureFn: (int level, _) => moodCounts[level],
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
    int mood0count = moods.where((mood) => mood.level == 0).length;
    int mood1count = moods.where((mood) => mood.level == 1).length;
    int mood2count = moods.where((mood) => mood.level == 2).length;
    int mood3count = moods.where((mood) => mood.level == 3).length;
    int mood4count = moods.where((mood) => mood.level == 4).length;
    int mood5count = moods.where((mood) => mood.level == 5).length;
    int mood6count = moods.where((mood) => mood.level == 6).length;
    int mood7count = moods.where((mood) => mood.level == 7).length;
    int mood8count = moods.where((mood) => mood.level == 8).length;
    List<int> moodCounts = [
      mood0count,
      mood1count,
      mood2count,
      mood3count,
      mood4count,
      mood5count,
      mood6count,
      mood7count,
      mood8count,
    ];
    List<int> moodLevels = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    List<charts.Series<int, int>> seriesList = [
      charts.Series<int, int>(
        id: 'Mood',
        colorFn: (level, value) {
          switch (level) {
            case 8:
              return charts.MaterialPalette.green.shadeDefault;
            case 7:
              return charts.MaterialPalette.green.shadeDefault;
            case 6:
              return charts.MaterialPalette.lime.shadeDefault;
            case 5:
              return charts.MaterialPalette.lime.shadeDefault;
            case 4:
              return charts.MaterialPalette.yellow.shadeDefault;
            case 3:
              return charts.MaterialPalette.deepOrange.shadeDefault;
            case 2:
              return charts.MaterialPalette.deepOrange.shadeDefault;
            case 1:
              return charts.MaterialPalette.red.shadeDefault;
            case 0:
              return charts.MaterialPalette.red.shadeDefault;
          }
        },
        domainFn: (int level, _) => level,
        measureFn: (int level, _) => moodCounts[level],
        data: moodLevels,
        labelAccessorFn: (int level, _) {
          return level.toString();
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
    String userId = Global.userId;
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
