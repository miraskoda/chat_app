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

  dynamic getFormattedDate(dynamic snaps) {
    bool notValid = snaps.data == null;
    String ret = !notValid
        ? DateFormat.d().format(snaps.data["createdAt"].toDate())
        : "";
    if (ret == DateFormat.d().format(DateTime.now())) {
      return DateFormat.Hm().format(snaps.data["createdAt"].toDate());
    }
    ret = notValid
        ? "No data"
        : DateFormat.Md().format(snaps.data["createdAt"].toDate());
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    //getImageUrl();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black45,
        title: FutureBuilder(
            future: getImageUrl(),
            builder: (BuildContext ctx, AsyncSnapshot<dynamic> snap) {
              //snap.data["username"];
              return snap.connectionState != ConnectionState.done
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(snap.data!["image_url"]),
                        ),
                        Text(snap.data!["username"]),
                        const SizedBox(
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
              icon: const Icon(Icons.settings)),
          TextButton(
            onPressed: () {
              logout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black45,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          //color: Colors.black26,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Open new chat:",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: StreamBuilder(
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? CircularProgressIndicator()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, index) => Container(
                                    child: Column(
                                      children: [
                                        FutureBuilder(
                                            future: getLastMess(snapshot
                                                .data.docs[index]["uId"]),
                                            builder: (BuildContext ctxs,
                                                AsyncSnapshot<dynamic> snaps) {
                                              return snaps.connectionState ==
                                                      ConnectionState.waiting
                                                  ? CircularProgressIndicator()
                                                  : Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            //print(snapshot.data.docs);
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                              ChatScreen
                                                                  .routeName,
                                                              arguments: snapshot
                                                                      .data
                                                                      .docs[
                                                                  index]["uId"],
                                                            );
                                                          },
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundImage:
                                                                      NetworkImage(snapshot
                                                                          .data
                                                                          .docs[index]["image_url"]),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 0,
                                                              ),
                                                              Container(
                                                                width: 140,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          0.0),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(snapshot
                                                                          .data
                                                                          .docs[index]["username"]),
                                                                      Text(snaps.data ==
                                                                              null
                                                                          ? "No messages"
                                                                          : (snaps
                                                                              .data["text"]))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 0,
                                                              ),
                                                              Container(
                                                                width: 60,
                                                                child: Text(
                                                                    getFormattedDate(
                                                                        snaps)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.8),
                                                              spreadRadius: 3,
                                                              blurRadius: 7,
                                                              offset: const Offset(
                                                                  0,
                                                                  1), // changes position of shadow
                                                            ),
                                                          ],
                                                          color:
                                                              Colors.blue[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    );
                                            }),
                                        const SizedBox(
                                          height: 20,
                                        )
                                      ],
                                    ),
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
        ),
      ),
    );
  }
}
