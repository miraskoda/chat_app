import 'dart:math';

import 'package:chat_app/widgets/mess_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final uId = FirebaseAuth.instance.currentUser!.uid;
    _enteredMessage = _messController.text;

    final userData =
        await FirebaseFirestore.instance.collection("users").doc(uId).get();
    final toUser =
        await FirebaseFirestore.instance.collection("users").doc(idUsers).get();

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
      "userIdTo": idUsers,
      "usernameFrom": userData["username"],
      "emailFrom": userData["email"],
    });

// duplicite with swaped Uid and targedMess userid, hence they show their messages
    FirebaseFirestore.instance
        .collection("messages")
        .doc(idUsers)
        .collection(uId)
        .add({
      "text": _enteredMessage,
      "createdAt": timestamp,
      "userId": uId,
      "userIdTo": idUsers,
      "usernameFrom": userData["username"],
      "emailFrom": userData["email"]
    });

    _messController.clear();
  }

  @override
  Widget build(BuildContext context) {
    idUsers = ModalRoute.of(context)!.settings.arguments as String;
    //print(uIdToMess);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Message screen "),
      ),
      body: Container(
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
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                                    ["usernameFrom"],
                                text: snapshot.data.docs[index]["text"],
                                email: snapshot.data.docs[index]["emailFrom"],
                                key: ValueKey(index),
                                isMe: Random().nextDouble() <= 0.7,
                                // isMe: true
                              );
                            },
                          );
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(2),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: TextField(
                        decoration: InputDecoration(labelText: "Send"),
                        controller: _messController,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sendMessage,
                      child: Text("Send"),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
