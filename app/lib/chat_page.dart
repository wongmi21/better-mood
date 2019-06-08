import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';

class ChatPage extends StatefulWidget {
  final String id;
  final String name;

  ChatPage(this.id, this.name);

  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  static final themeColor = Color(0xfff5a623);
  static final primaryColor = Color(0xff203152);
  static final greyColor = Color(0xffaeaeae);
  static final greyColor2 = Color(0xffE8E8E8);

  final FocusNode focusNode = new FocusNode();
  final TextEditingController inputTextController = TextEditingController();
  bool showEmojiKeyboard = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Chat - ${widget.name}')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(title: Text('ad')),
                ],
              ),
            ),
            showEmojiKeyboard
                ? EmojiPicker(
                    rows: 3,
                    columns: 7,
                    onEmojiSelected: (emoji, category) {
                      inputTextController.text += emoji.emoji;
                    },
                  )
                : Container(),
            inputBox,
          ],
        ),
      );

  get inputBox {
    return Container(
      child: Row(
        children: [
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.insert_emoticon),
                onPressed: () => setState(() {
                      showEmojiKeyboard = !showEmojiKeyboard;
                    }),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                controller: inputTextController,
                style: TextStyle(fontSize: 15.0),
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
              ),
            ),
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {},
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 40.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }
}
