import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String imageUrl = "";
  String username = "";

  Future<QueryDocumentSnapshot> getImageUrl() async {
    final id = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await _collectionRef.get(const GetOptions(source: Source.server));

    return querySnapshot.docs.firstWhere((element) {
      return element.id == id;
    });
  }

  Future<Object> getLastMess(String id) async {
    //.doc(idUsers)
    //  .collection(uId)
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(id)
        .collection(FirebaseAuth.instance.currentUser!.uid);
    QuerySnapshot querySnapshot =
        await _collectionRef.get(const GetOptions(source: Source.server));

    if (querySnapshot.docs.last.exists) {
      return querySnapshot.docs.last;
    } else {
      return false;
    }
    // return querySnapshot.docs.firstWhere((element) {
    //   return element.id == id;
    // });
  }

  @override
  Widget build(BuildContext context) {
    //getImageUrl();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: FutureBuilder(
            future: getImageUrl(),
            builder: (BuildContext ctx, AsyncSnapshot<dynamic> snap) {
              //snap.data["username"];
              return snap.connectionState != ConnectionState.done
                  ? CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(snap.data!["image_url"]),
                        ),
                        Text(snap.data!["username"]),
                        SizedBox(
                          width: 90,
                        ),
                      ],
                    );
            }),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              },
              icon: Icon(Icons.settings)),
          TextButton(
            onPressed: () {
              logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Conversations:",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: StreamBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? CircularProgressIndicator()
                          : ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (ctx, index) => Column(
                                children: [
                                  FutureBuilder(
                                      future: getLastMess(
                                          snapshot.data.docs[index]["uId"]),
                                      builder: (BuildContext ctxs,
                                          AsyncSnapshot<dynamic> snaps) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                //print(snapshot.data.docs);
                                                Navigator.of(context).pushNamed(
                                                  ChatScreen.routeName,
                                                  arguments: snapshot
                                                      .data.docs[index]["uId"],
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                                .data
                                                                .docs[index]
                                                            ["image_url"]),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(snapshot.data
                                                                .docs[index]
                                                            ["username"]),
                                                        Text(snaps.data == null
                                                            ? "No messages"
                                                            : (snaps
                                                                .data["text"]))
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 90,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Text(snaps.data ==
                                                            null
                                                        ? ""
                                                        : DateFormat.yMMMd()
                                                            .format((snaps.data[
                                                                        "createdAt"]
                                                                    .toDate()
                                                                as DateTime))),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.blue[200],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        );
                                      }),
                                  const SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                              itemCount: snapshot.data.docs.length,
                            );
                    },
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
