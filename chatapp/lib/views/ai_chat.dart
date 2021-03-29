import 'dart:async';
import 'package:dialogflow_grpc/v2beta1.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'home.dart';

class Chat extends StatefulWidget {
  final String name;
  Chat(this.name);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();

  DialogflowGrpcV2Beta1 dialogflow;

  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  Future<void> initPlugin() async {
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/keys/credentials.json'))}');
    // Create a DialogflowGrpc Instance
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
  }

  void handleSubmitted(text) async {
    //print(text);
    _textController.clear();

    ChatMessage message = ChatMessage(
      text: text,
      ts: DateTime.now(),
      type: true,
    );

    setState(() {
      _messages.insert(0, message);
    });

    String fulfillmentText = "";
    try {
      DetectIntentResponse data = await dialogflow.detectIntent(text, 'en-US');
      fulfillmentText = data.queryResult.fulfillmentText;
      //print(fulfillmentText);
    } catch (e) {
      print(e);
    }

    if (fulfillmentText.isNotEmpty) {
      ChatMessage botMessage = ChatMessage(
        text: fulfillmentText,
        ts: DateTime.now(),
        type: false,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1d1d1d),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xff232323),
            statusBarIconBrightness: Brightness.light),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: Color(0xffF4C2C2),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
              _messages.clear();
              setState(() {});
            }),
        title: Text(
          "Athena",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffF4C2C2)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover)),
        child: Stack(children: [
          Column(children: <Widget>[
            Flexible(
                child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            )),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: Color(0xffF4C2C2)),
                        onSubmitted: handleSubmitted,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message",
                            hintStyle: TextStyle(
                                color: Color(0xffF4C2C2).withOpacity(0.6))),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Color(0xffF4C2C2),
                      ),
                      onPressed: () => handleSubmitted(_textController.text),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.ts, this.type});

  final String text;
  final DateTime ts;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(0),
                ),
                color: Color(0xffF4C2C2),
              ),
              padding: EdgeInsets.all(16),
              child: RichText(
                  text: TextSpan(
                      text: text,
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                        text: "      " +
                            timeago
                                .format(this.ts, locale: "en_short")
                                .replaceAll("~", ""),
                        style: TextStyle(color: Colors.black.withOpacity(0.6)))
                  ])),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight: Radius.circular(0),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                color: Color(0xff1d1d1d),
              ),
              padding: EdgeInsets.all(16),
              child: RichText(
                  text: TextSpan(
                      text: text,
                      style: TextStyle(color: Color(0xffF4C2C2)),
                      children: <TextSpan>[
                    TextSpan(
                        text: "      " +
                            timeago
                                .format(this.ts, locale: "en_short")
                                .replaceAll("~", ""),
                        style: TextStyle(color: Colors.white.withOpacity(0.3)))
                  ])),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
