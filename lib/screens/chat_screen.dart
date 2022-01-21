import 'dart:convert';
import 'dart:math';

import 'package:chat_app/assets/theme_state.dart';
import 'package:chat_app/widgets/mess_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const routeName = "/chat";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String idUsers = "";

  final _messController = TextEditingController();
  String _enteredMessage = "";

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<DocumentSnapshot> getImage() async {
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return userData;
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final uId = FirebaseAuth.instance.currentUser!.uid;
    _enteredMessage = _messController.text;

    final userData =
        await FirebaseFirestore.instance.collection("users").doc(uId).get();

    var timestamp = Timestamp.now();
// sending message to one of possible collections
    FirebaseFirestore.instance
        .collection("messages")
        .doc(uId)
        .collection(idUsers)
        .add({
      "text": _enteredMessage,
      "createdAt": timestamp,
      "userId": uId,
      "username": userData["username"],
    });

    if (uId != idUsers) {
// duplicite with swaped Uid and targedMess userid, hence they show their messages
      FirebaseFirestore.instance
          .collection("messages")
          .doc(idUsers)
          .collection(uId)
          .add({
        "text": _enteredMessage,
        "createdAt": timestamp,
        "userId": uId,
        "username": userData["username"],
      });
    }
    _messController.clear();
  }

  @override
  Widget build(BuildContext context) {
    idUsers = ModalRoute.of(context)!.settings.arguments as String;
    //print(uIdToMess);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black45,
        title: FutureBuilder(
          future: getImage(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? Padding(
                    padding: const EdgeInsets.only(left: 45.0),
                    child: Text("Chat: " + snapshot.data["username"]),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
      body: Container(
        color: Colors.black45,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: Provider.of<ThemeState>(context).theme == ThemeType.DARK
                ? Colors.grey
                : Colors.blue[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("messages")
                        .doc(FirebaseAuth
                            .instance.currentUser?.uid) // current logged user
                        .collection(idUsers)
                        .orderBy("createdAt", descending: true)
                        // person who wants to send mess
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return messBuble(
                                  username: snapshot.data.docs[index]
                                      ["username"],
                                  text: snapshot.data.docs[index]["text"],
                                  isMe:
                                      FirebaseAuth.instance.currentUser!.uid ==
                                          snapshot.data.docs[index]["userId"],
                                  userId: snapshot.data.docs[index]["userId"],
                                );
                              },
                            );
                    },
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.black38),
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 5, bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: TextField(
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            isDense: true, // Added this
                            contentPadding: EdgeInsets.all(8), // Added this
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context)!.writeMess,
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                          controller: _messController,
                        ),
                      ),
                    ),
                    Container(
                      // height: 40,
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        child: Text(
                          AppLocalizations.of(context)!.sendButton,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            elevation: MaterialStateProperty.all(10),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
