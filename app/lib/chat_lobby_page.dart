import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';
import 'drawer.dart';
import 'globals.dart';

class ChatLobbyPage extends StatefulWidget {
  ChatLobbyPageState createState() => ChatLobbyPageState();
}

class ChatLobbyPageState extends State<ChatLobbyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Chats')),
      drawer: BetterMoodDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: Global.firestore.collection('chats').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) =>
                snapshot.hasData
                    ? ListView(
                        children: listViewChildren(snapshot.data),
                      )
                    : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showAddGroupChatDialog(),
      ),
    );
  }

  List<ListTile> listViewChildren(QuerySnapshot snapshot) {
    return snapshot.documents
        .map((doc) => ListTile(
              leading: CircleAvatar(
                  child: Image(image: AssetImage('assets/imh_icon.jpg'))),
              title: Text(doc.data['name']),
              subtitle: Text(doc.data['description']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => showDeleteGroupChatDialog(doc),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Chat(doc.documentID, doc.data['name']))),
            ))
        .toList();
  }

  void showAddGroupChatDialog() {
    String name = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Add Group Chat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => name = val,
                  decoration: InputDecoration(hintText: "Name"),
                ),
                TextField(
                  onChanged: (val) => description = val,
                  decoration: InputDecoration(hintText: "Description"),
                ),
              ],
            ),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Global.firestore
                      .collection('chats')
                      .where('name', isEqualTo: name)
                      .getDocuments()
                      .then((snapshot) {
                    Global.firestore.collection('chats').document().setData({
                      'name': name,
                      'description': description,
                    });
                    Navigator.of(context).pop();
                  });
                },
              ),
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
    );
  }

  void showDeleteGroupChatDialog(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Delete Group Chat"),
            content: Text('Are you sure you want to delete ${doc['name']}?'),
            actions: [
              FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Global.firestore
                        .collection('chats')
                        .document(doc.documentID)
                        .delete();
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
    );
  }
}
