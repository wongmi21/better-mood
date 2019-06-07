import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'globals.dart';

class EventsPage extends StatefulWidget {
  @override
  State<EventsPage> createState() {
    return EventsPageState();
  }
}

class EventsPageState extends State<EventsPage> {
  final TextEditingController searchController = TextEditingController();
  String filter = 'all_events';
  bool searchMode = false;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });
    return Scaffold(
      appBar: AppBar(
        leading: searchMode ? Icon(Icons.search) : null,
        title: (() {
          return searchMode
              ? TextField(
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white54),
                  ))
              : Text('Events');
        })(),
        actions: (() {
          return searchMode
              ? [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        searchController.text = '';
                        searchMode = false;
                      });
                    },
                  ),
                ]
              : [
                  PopupMenuButton(
                    initialValue: filter,
                    icon: Icon(Icons.filter_list),
                    itemBuilder: (context) => <PopupMenuEntry>[
                          PopupMenuItem(
                              value: 'all_events', child: Text('All Events')),
                          PopupMenuDivider(),
                          PopupMenuItem(value: 'imh', child: Text('IMH')),
                          PopupMenuItem(value: 'meetup', child: Text('Meetup')),
                          PopupMenuItem(
                              value: 'eventbrite', child: Text('Eventbrite')),
                          PopupMenuItem(
                              value: 'clubheal', child: Text('Club Heal')),
                          PopupMenuItem(
                              value: 'psaltcare', child: Text('Psaltcare')),
                        ],
                    onSelected: (value) {
                      setState(() {
                        filter = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchMode = true;
                      });
                    },
                  ),
                ];
        })(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Global.firestore.collection('events').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            List<DocumentSnapshot> documents = snapshot.data.documents;
            documents.sort(
                (a, b) => a['end']['datetime'].compareTo(b['end']['datetime']));
            documents.removeWhere(
                (doc) => filter != 'all_events' && !(doc['source'] == filter));
            if (searchText != null) {
              documents.removeWhere((doc) => !doc['name']
                  .toLowerCase()
                  .contains(searchText.toLowerCase()));
            }
            return ListView(
              children: documents.map(
                (document) {
                  Image image;
                  switch (document['source']) {
                    case 'meetup':
                      image = fromUrl('assets/meetup_logo.png');
                      break;
                    case 'eventbrite':
                      image = fromUrl('assets/eventbrite_logo.png');
                      break;
                    case 'imh':
                      image = fromUrl('assets/imh_logo.jpg');
                      break;
                    case 'clubheal':
                      image = fromUrl('assets/clubheal_logo.png');
                      break;
                    case 'psaltcare':
                      image = fromUrl(document['image']);
                      break;
                    case 'samh': 
                      image = fromUrl('assets/samh_logo.png');
                      break;
                  }
                  String eventStartDate = DateFormat('d MMM yyyy')
                      .format(document['start']['datetime'].toDate());
                  String eventEndDate = DateFormat('d MMM yyyy')
                      .format(document['end']['datetime'].toDate());
                  String eventDateRange;
                  if (eventStartDate == eventEndDate) {
                    eventDateRange = DateFormat('EEEE, d MMM yyyy\nh:mm a to ')
                            .format(document['start']['datetime'].toDate()) +
                        DateFormat('h:mm a')
                            .format(document['end']['datetime'].toDate());
                  } else {
                    eventDateRange = DateFormat('EEEE, d MMM yyyy, h:mm a to\n')
                            .format(document['start']['datetime'].toDate()) +
                        DateFormat('EEEE, d MMM yyyy, h:mm a')
                            .format(document['end']['datetime'].toDate());
                  }

                  return ListTile(
                    title: Text(document['name']),
                    leading: image,
                    subtitle: Text(eventDateRange),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WebViewContainer(),
                          settings: RouteSettings(
                            arguments: [document['name'], document['url']],
                          ),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            );
          }
        },
      ),
    );
  }

  Image fromUrl(imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        width: 50.0,
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        width: 50.0,
      );
    }
  }
}

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class WebViewContainer extends StatefulWidget {
  @override
  State<WebViewContainer> createState() {
    return WebViewState();
  }
}

class WebViewState extends State<WebViewContainer> {
  int _index = 0;

  void handleLoad(String value) {
    setState(() {
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List args = ModalRoute.of(context).settings.arguments;
    String title = args[0];
    String url = args[1];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: IndexedStack(index: _index, children: [
        Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: handleLoad,
        ),
      ]),
    );
  }
}
