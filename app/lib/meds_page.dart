import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'drawer.dart';

class MedsPage extends StatefulWidget {
  @override
  State<MedsPage> createState() {
    return MedsPageState();
  }
}

class MedsPageState extends State<MedsPage> {
  Future<Database> futureDb;
  Calendar calendar;
  DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    calendar = Calendar(onDateSelected: (DateTime dateTime) {
      setState(() {
        selectedDate = dateTime;
      });
    });
    futureDb = getFutureDb();
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;
    selectedDate = DateTime.utc(year, month, day);
  }

  Future<Database> getFutureDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'meds.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE meds(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, dosage TEXT, start_date TEXT, end_date TEXT)");
        db.execute(
            "CREATE TABLE meds_schedule(id INTEGER PRIMARY KEY AUTOINCREMENT, med_id INTEGER, time TEXT, frequency TEXT)");
        db.execute(
            "CREATE TABLE meds_intake(id INTEGER PRIMARY KEY AUTOINCREMENT, med_id INTEGER, date TEXT, status TEXT)");
      },
      version: 2,
    );
  }

  Future<List<Med>> getFutureMeds() async {
    Database db = await futureDb;
    List<Map<String, dynamic>> maps = await db.query('meds');
    return List.generate(maps.length, (i) {
      String startDateString = maps[i]['start_date'];
      String endDateString = maps[i]['end_date'];
      DateTime startDate = startDateString == null
          ? null
          : DateTime.parse(maps[i]['start_date']);
      DateTime endDate =
          endDateString == null ? null : DateTime.parse(maps[i]['end_date']);

      return Med(
        maps[i]['id'],
        maps[i]['name'],
        maps[i]['dosage'],
        startDate,
        endDate,
      );
    });
  }

  Future<void> dbSnapshot() async {
    Database db = await futureDb;
    db.rawQuery('select * from meds').then(
          (x) => print('meds: ' + x.toString()),
        );
    db.rawQuery('select * from meds_schedule').then(
          (x) => print('meds_schedule: ' + x.toString()),
        );
    db.rawQuery('select * from meds_intake').then(
          (x) => print('meds_intake: ' + x.toString()),
        );
  }

  Future<List<MedCard>> futureMedCards() async {
    Database db = await futureDb;
    List<Med> meds = await getFutureMeds();
    for (Med med in meds) {
      List<Map<String, dynamic>> mapsMedsSchedule =
          await db.query('meds_schedule', where: 'med_id=' + med.id.toString());
      List<MedSchedule> medsSchedules =
          List.generate(mapsMedsSchedule.length, (i) {
        String timeString = mapsMedsSchedule[i]['time'];
        return MedSchedule(
            time: timeString == null ? null : DateTime.parse(timeString),
            frequency: mapsMedsSchedule[i]['frequency']);
      });
      med.schedules = medsSchedules;
      List<Map<String, dynamic>> mapsMedsIntake =
          await db.query('meds_intake', where: 'med_id=' + med.id.toString());
      List<MedIntake> medIntakes = List.generate(mapsMedsIntake.length, (i) {
        String dateString = mapsMedsIntake[i]['date'];
        return MedIntake(dateString == null ? null : DateTime.parse(dateString),
            mapsMedsIntake[i]['status']);
      });
      med.intakes = medIntakes;
    }
    return meds.map((Med med) {
      Color cardColor = Colors.white;
      List<MedIntake> medIntakes = med.intakes
          .where((medIntake) => medIntake.date == selectedDate)
          .toList();
      MedIntake medIntake = medIntakes.length > 0 ? medIntakes[0] : null;
      if (medIntake != null) {
        switch (medIntake.status) {
          case 'taken':
            {
              cardColor = Colors.green.shade200;
            }
            break;
          case 'skipped':
            {
              cardColor = Colors.red.shade200;
            }
            break;
        }
      }
      return MedCard(
        med,
        () async {
          await db.delete('meds', where: 'id=' + med.id.toString());
          await db.delete('meds_schedule',
              where: 'med_id=' + med.id.toString());
          await db.delete('meds_intake', where: 'med_id=' + med.id.toString());
          setState(() {});
        },
        (status) async {
          int updateValue = await db.update('meds_intake',
              Map.fromEntries([MapEntry<String, String>('status', status)]),
              where: 'med_id=? AND date=?',
              whereArgs: [med.id.toString(), selectedDate.toIso8601String()]);
          if (updateValue == 0) {
            await db.insert(
              'meds_intake',
              Map.fromEntries(
                [
                  MapEntry<String, int>('med_id', med.id),
                  MapEntry<String, String>(
                      'date', selectedDate.toIso8601String()),
                  MapEntry<String, String>('status', status)
                ],
              ),
            );
          }
          setState(() {});
        },
        cardColor,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    dbSnapshot();
    return Scaffold(
        appBar: AppBar(title: Text('Medications')),
        drawer: BetterMoodDrawer(),
        body: ListView(children: [
          calendar,
          FutureBuilder(
            future: futureMedCards(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Column(children: snapshot.hasData ? snapshot.data : []);
            },
          ),
        ]),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return AddMedicationPage((String name,
                    String dosage,
                    DateTime startDate,
                    DateTime endDate,
                    List<MedSchedule> medsSchedules) async {
                  Database db = await futureDb;
                  int medId = await db.insert(
                      'meds',
                      {
                        'name': name,
                        'dosage': dosage,
                        'start_date': startDate == null
                            ? null
                            : startDate.toIso8601String(),
                        'end_date':
                            endDate == null ? null : endDate.toIso8601String(),
                      },
                      conflictAlgorithm: ConflictAlgorithm.replace);
                  for (MedSchedule medsSchedule in medsSchedules) {
                    await db.insert(
                        'meds_schedule',
                        {
                          'med_id': medId,
                          'time': medsSchedule.time == null
                              ? null
                              : medsSchedule.time.toIso8601String(),
                          'frequency': medsSchedule.frequency,
                        },
                        conflictAlgorithm: ConflictAlgorithm.replace);
                  }

                  setState(() {});
                });
              }));
            }));
  }
}

class MedCard extends StatefulWidget {
  final Med med;
  final VoidCallback onDelete;
  final Function(String) onChangeStatus;
  final Color color;

  Future<String> get futurePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get futureImage async {
    final path = await futurePath;
    return File('$path/' + med.id.toString() + '.png');
  }

  Future<bool> get futureImageExists async {
    return (await futureImage).exists();
  }

  MedCard(this.med, this.onDelete, this.onChangeStatus, this.color);

  @override
  State<MedCard> createState() {
    return MedCardState();
  }
}

class MedCardState extends State<MedCard> {
  Color color;

  Future<String> get futurePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get futureImage async {
    final path = await futurePath;
    return File('$path/' + widget.med.id.toString() + '.png');
  }

  Future<bool> get futureImageExists async {
    return (await futureImage).exists();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      child: FutureBuilder<List>(
        future: Future.wait([futureImageExists, futureImage]),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          return !snapshot.hasData
              ? Container()
              : Row(
                  children: [
                  !snapshot.data[0]
                      ? null
                      : GestureDetector(
                          child: Image.file(snapshot.data[1], width: 50),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return Scaffold(
                                  appBar: AppBar(
                                    title: Text('Image Picker Example'),
                                  ),
                                  body: Center(
                                      child: Image.file(snapshot.data[1])));
                            }));
                          },
                        ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () async {
                              await futureImage.then((image) => image.delete());
                              widget.onDelete();
                            },
                          ),
                          leading: !snapshot.data[0]
                              ? IconButton(
                                  icon: Icon(Icons.add_a_photo),
                                  onPressed: () async {
                                    String path = await futurePath;
                                    File newImage = await ImagePicker.pickImage(
                                        source: ImageSource.camera);
                                    await (newImage).copy('$path/' +
                                        widget.med.id.toString() +
                                        '.png');
                                    setState(() {});
                                  },
                                )
                              : null,
                          title: Text(createTitle()),
                          subtitle: Text(createSubtitle()),
                        ),
                        ButtonTheme.bar(
                          // make buttons use the appropriate styles for cards
                          child: ButtonBar(
                            children: [
                              FlatButton(
                                child: Text('TAKE'),
                                onPressed: () => widget.onChangeStatus('taken'),
                              ),
                              FlatButton(
                                child: Text('SKIP'),
                                onPressed: () =>
                                    widget.onChangeStatus('skipped'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ].where((x) => x != null).toList());
        },
      ),
    );
  }

  String createTitle() {
    String name = widget.med.name;
    String dosage = widget.med.dosage;
    String suffix = dosage == null ? '' : ' - ' + dosage;
    return name + suffix;
  }

  String createSubtitle() {
    DateTime startDate = widget.med.startDate;
    DateTime endDate = widget.med.endDate;
    String startDateString =
        startDate == null ? '' : DateFormat('d MMM yyyy').format(startDate);
    String endDateString =
        endDate == null ? '' : DateFormat('d MMM yyyy').format(endDate);
    List<String> lines = [];
    String firstLine;
    if (startDate != null && endDate != null) {
      firstLine = startDateString + ' to ' + endDateString;
      lines.add(firstLine);
    } else if (startDate != null) {
      firstLine = 'Starting ' + startDateString;
      lines.add(firstLine);
    } else if (endDate != null) {
      firstLine = 'Ending ' + endDateString;
      lines.add(firstLine);
    }
    widget.med.schedules.forEach((medsSchedule) {
      DateTime time = medsSchedule.time;
      String timeString = time == null ? '' : DateFormat('h:mm a').format(time);
      String frequency = medsSchedule.frequency;
      String line = frequency + (time == null ? '' : ' at ' + timeString);
      lines.add(line);
    });
    return lines.join('\n');
  }
}

class AddMedicationPage extends StatefulWidget {
  final Function(String name, String dosage, DateTime startDate,
      DateTime endDate, List<MedSchedule> medsSchedules) addMedCard;

  AddMedicationPage(this.addMedCard);

  @override
  State<AddMedicationPage> createState() {
    return AddMedicationPageState();
  }
}

class AddMedicationPageState extends State<AddMedicationPage> {
  String name;
  String dosage;
  DateTime startDate;
  DateTime endDate;
  List<MedSchedule> medsSchedules = [MedSchedule()];

  @override
  Widget build(BuildContext context) {
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    if (startDate != null) {
      startDateController.text = DateFormat('d MMM yyyy').format(startDate);
    }
    if (endDate != null) {
      endDateController.text = DateFormat('d MMM yyyy').format(endDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medication'),
        actions: [
          FlatButton(
            child: Text('Save', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (name == null || name.isEmpty) {
                showDialog(
                  context: context,
                  builder: (_) {
                    AlertDialog prompt = AlertDialog(
                      title: Text('Medication name cannot be empty!'),
                    );
                    return prompt;
                  },
                );
                return;
              }
              widget.addMedCard(
                  name, dosage, startDate, endDate, medsSchedules);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: ImageIcon(AssetImage('assets/meds_icon.png')),
            title: TextField(
              decoration: InputDecoration(
                hintText: "Medication Name",
              ),
              onChanged: (val) {
                setState(() {
                  name = val;
                });
              },
            ),
          ),
          ListTile(
            leading: ImageIcon(AssetImage('assets/dosage_icon.png')),
            title: TextField(
              decoration: InputDecoration(
                hintText: "Dosage",
              ),
              onChanged: (val) {
                setState(() {
                  dosage = val;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.date_range),
            title: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: startDateController,
                    focusNode: AlwaysDisabledFocusNode(),
                    decoration: InputDecoration(
                      hintText: "Start Date",
                    ),
                    onTap: () {
                      selectStartDate(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                Flexible(
                  child: TextField(
                    controller: endDateController,
                    focusNode: AlwaysDisabledFocusNode(),
                    decoration: InputDecoration(
                      hintText: "End Date",
                    ),
                    onTap: () {
                      selectEndDate(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Column(
              children: medsSchedules
                  .map((medsSchedule) => MedsScheduleListTile(medsSchedule))
                  .toList()),
          ListTile(
            title: RaisedButton(
              child: Text('Add Time'),
              onPressed: () {
                addMedsScheduleListTile();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null)
      setState(() {
        startDate = picked;
      });
  }

  Future<Null> selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null)
      setState(() {
        endDate = picked;
      });
  }

  void addMedsScheduleListTile() {
    List<MedSchedule> updatedMedsSchedule = List.from(medsSchedules);
    updatedMedsSchedule.add(MedSchedule());
    setState(() {
      medsSchedules = updatedMedsSchedule;
    });
  }
}

class MedSchedule {
  DateTime time;
  String frequency;

  MedSchedule({this.time, this.frequency = 'Everyday'});
}

class MedsScheduleListTile extends StatefulWidget {
  final MedSchedule medsSchedule;

  const MedsScheduleListTile(this.medsSchedule);

  @override
  State<MedsScheduleListTile> createState() {
    return MedsScheduleListTileState(medsSchedule);
  }
}

class MedsScheduleListTileState extends State<MedsScheduleListTile> {
  MedSchedule medsSchedule;
  TextEditingController timeController = TextEditingController();

  MedsScheduleListTileState(this.medsSchedule);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.access_time),
      title: Row(children: [
        Flexible(
          child: TextField(
            controller: timeController,
            focusNode: AlwaysDisabledFocusNode(),
            decoration: InputDecoration(
              hintText: "Time",
            ),
            onTap: () {
              DatePicker.showTimePicker(
                context,
                currentTime: DateFormat('hh:mm:ss').parse('19:00:00'),
                onConfirm: (DateTime dateTime) {
                  timeController.text =
                      DateFormat('h:mm:ss a').format(dateTime).toString();
                  setState(() {
                    medsSchedule.time = dateTime;
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Expanded(
          child: DropdownButtonFormField(
            value: medsSchedule.frequency,
            onChanged: (val) {
              setState(() {
                medsSchedule.frequency = val;
              });
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10)),
            items: <DropdownMenuItem>[
              DropdownMenuItem<String>(
                value: 'Everyday',
                child: Text('Everyday'),
              ),
              DropdownMenuItem<String>(
                value: 'Every 2 days',
                child: Text('Every 2 days'),
              ),
              DropdownMenuItem<String>(
                value: 'Every 3 days',
                child: Text('Every 3 days'),
              ),
              DropdownMenuItem<String>(
                value: 'Every week',
                child: Text('Every week'),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class Med {
  final int id;
  final String name;
  final String dosage;
  final DateTime startDate;
  final DateTime endDate;
  List<MedSchedule> schedules;
  List<MedIntake> intakes;

  Med(this.id, this.name, this.dosage, this.startDate, this.endDate,
      {this.schedules, this.intakes});
}

class MedIntake {
  final String status;
  final DateTime date;

  MedIntake(this.date, this.status);
}
