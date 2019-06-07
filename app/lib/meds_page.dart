import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'drawer.dart';
import 'globals.dart';

class MedsPage extends StatefulWidget {
  @override
  State<MedsPage> createState() {
    return MedsPageState();
  }
}

class MedsPageState extends State<MedsPage> {
  Calendar calendar;
  DateTime selectedDate;
  List<Medication> _medications = [];
  StreamSubscription<QuerySnapshot> _medsDbListener;

  @override
  void initState() {
    super.initState();
    initMedications();
    calendar = Calendar(onDateSelected: (DateTime dateTime) {
      setState(() {
        selectedDate = dateTime;
      });
    });
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;
    selectedDate = DateTime.utc(year, month, day, 12);
  }

  void initMedications() async {
    StreamSubscription<QuerySnapshot> medsDbListener = Global.firestore
        .collection('medications')
        .where('userId', isEqualTo: Global.userId)
        .snapshots()
        .listen(onMedicationsUpdated);
    setState(() {
      _medsDbListener = medsDbListener;
    });
  }

  void onMedicationsUpdated(QuerySnapshot snapshot) async {
    print(
        '----------------------------------UPDATED----------------------------------');
    List<Future<Medication>> futureMeds =
        snapshot.documents.map((documentSnapshot) async {
      QuerySnapshot schedulesSnapshot = await documentSnapshot.reference
          .collection('schedules')
          .getDocuments();
      List<MedicationSchedule> schedules = schedulesSnapshot.documents
          .map((scheduleSnapshot) => MedicationSchedule(
              time: (scheduleSnapshot.data['time'] as Timestamp)?.toDate(),
              frequency: scheduleSnapshot.data['frequency']))
          .toList();
      QuerySnapshot intakesSnapshot =
          await documentSnapshot.reference.collection('intakes').getDocuments();
      List<MedicationIntake> intakes = intakesSnapshot.documents
          .map((intakesSnapshot) => MedicationIntake(
              DateTime.parse(intakesSnapshot.documentID),
              intakesSnapshot.data['status']))
          .toList();
      return Medication(
        documentSnapshot.documentID,
        documentSnapshot.data['name'],
        documentSnapshot.data['dosage'],
        (documentSnapshot.data['startDate'] as Timestamp)?.toDate(),
        (documentSnapshot.data['endDate'] as Timestamp)?.toDate(),
        schedules: schedules,
        intakes: intakes,
      );
    }).toList();

    List<Medication> medications = await Future.wait(futureMeds);
    setState(() {
      _medications = medications;
    });
  }

  List<MedCard> createtMedCards() {
    return _medications.map((Medication medication) {
      Color cardColor = Colors.white;
      List<MedicationIntake> medIntakes = medication.intakes
          .where((medIntake) => medIntake.date == selectedDate)
          .toList();
      MedicationIntake medIntake = medIntakes.length > 0 ? medIntakes[0] : null;
      if (medIntake != null) {
        switch (medIntake.status) {
          case 'taken':
            cardColor = Colors.green.shade200;
            break;
          case 'skipped':
            cardColor = Colors.red.shade200;
            break;
        }
      }
      return MedCard(
        medication,
        () {
          // onDelete
          Global.firestore
              .collection('medications')
              .document(medication.id)
              .delete();
        },
        (status) {
          // onChangeStatus
          CollectionReference docIntakes = Global.firestore
              .collection('medications')
              .document(medication.id)
              .collection('intakes');
          docIntakes
              .document(selectedDate.toIso8601String())
              .setData({'status': status});
        },
        cardColor,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medications')),
      drawer: BetterMoodDrawer(),
      body: ListView(children: [
        calendar,
        Column(children: createtMedCards())
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return AddMedicationPage(
                  (String name,
                      String dosage,
                      DateTime startDate,
                      DateTime endDate,
                      List<MedicationSchedule> medSchedules) async {
                    Global.firestore.collection('medications').add({
                      'userId': Global.userId,
                      'name': name,
                      'dosage': dosage,
                      'startDate': startDate,
                      'endDate': endDate,
                    }).then(
                      (docRef) {
                        for (MedicationSchedule medSchedule in medSchedules) {
                          docRef.collection('schedules').add({
                            'time': medSchedule.time ??
                                medSchedule.time.toIso8601String(),
                            'frequency': medSchedule.frequency,
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _medsDbListener.cancel();
  }
}

class MedCard extends StatefulWidget {
  final Medication med;
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
                              await futureImage.then((image) {
                                bool pathExists =
                                    FileSystemEntity.typeSync(image.path) !=
                                        FileSystemEntityType.notFound;
                                if (pathExists) image.delete();
                              });
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
      DateTime endDate, List<MedicationSchedule> medsSchedules) addMedCard;

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
  List<MedicationSchedule> medsSchedules = [MedicationSchedule()];

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
    List<MedicationSchedule> updatedMedsSchedule = List.from(medsSchedules);
    updatedMedsSchedule.add(MedicationSchedule());
    setState(() {
      medsSchedules = updatedMedsSchedule;
    });
  }
}

class MedicationSchedule {
  DateTime time;
  String frequency;

  MedicationSchedule({this.time, this.frequency = 'Everyday'});
}

class MedsScheduleListTile extends StatefulWidget {
  final MedicationSchedule medsSchedule;

  const MedsScheduleListTile(this.medsSchedule);

  @override
  State<MedsScheduleListTile> createState() {
    return MedsScheduleListTileState(medsSchedule);
  }
}

class MedsScheduleListTileState extends State<MedsScheduleListTile> {
  MedicationSchedule medsSchedule;
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

class Medication {
  final String id;
  final String name;
  final String dosage;
  final DateTime startDate;
  final DateTime endDate;
  List<MedicationSchedule> schedules;
  List<MedicationIntake> intakes;

  Medication(this.id, this.name, this.dosage, this.startDate, this.endDate,
      {this.schedules, this.intakes});
}

class MedicationIntake {
  final String status;
  final DateTime date;

  MedicationIntake(this.date, this.status);
}
