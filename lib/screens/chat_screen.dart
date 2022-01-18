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
        backgroundColor: Colors.black87,
        title: FutureBuilder(
          future: getImage(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? Text("Chat: " + snapshot.data["username"])
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
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
                                username: snapshot.data.docs[index]["username"],
                                text: snapshot.data.docs[index]["text"],
                                isMe: FirebaseAuth.instance.currentUser!.uid ==
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
