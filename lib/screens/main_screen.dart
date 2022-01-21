import 'dart:ffi';
import 'dart:math';

import 'package:chat_app/assets/theme_state.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {});
  }

  String imageUrl = "";
  String username = "";

  Future<DocumentSnapshot> getImageUrl() async {
    final id = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection('users').doc(id).get();
  }

  Future<Object> getLastMess(String id) async {
    //.doc(idUsers)
    //  .collection(uId)
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(id)
        .collection(FirebaseAuth.instance.currentUser!.uid);
    QuerySnapshot querySnapshot =
        await _collectionRef.orderBy("createdAt").get();

    if (querySnapshot.docs.last.exists) {
      return querySnapshot.docs.last;
    } else {
      return false;
    }
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
        ? AppLocalizations.of(context)!.noData
        : DateFormat.Md().format(snaps.data["createdAt"].toDate());
    return ret;
  }

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //getImageUrl();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.black45,
        title: FutureBuilder(
            future: getImageUrl(),
            builder: (BuildContext ctx, AsyncSnapshot<dynamic> snap) {
              //snap.data["username"];
              return snap.connectionState != ConnectionState.done ||
                      !snap.hasData
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          key: UniqueKey(),
                          backgroundImage:
                              NetworkImage(snap.data!["image_url"]),
                        ),
                        Text(snap.data!["username"]),
                        const SizedBox(
                          width: 60,
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
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black45,
        child: Container(
          margin: const EdgeInsets.only(top: 30),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Provider.of<ThemeState>(context).theme == ThemeType.DARK
                ? Colors.grey
                : Colors.blue[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      AppLocalizations.of(context)!.welcomeText,
                      // "Open new chat:",
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
                              ? const CircularProgressIndicator()
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
                                                  ? const CircularProgressIndicator()
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
                                                              const SizedBox(
                                                                width: 0,
                                                              ),
                                                              Container(
                                                                width: 180,
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
                                                                      Text(
                                                                        snapshot
                                                                            .data
                                                                            .docs[index]["username"],
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      Text(
                                                                        snaps.data ==
                                                                                null
                                                                            ? AppLocalizations.of(context)!.noMess
                                                                            : (snaps.data["text"]),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white),
                                                                      )
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
                                                                      snaps),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
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
                                                              spreadRadius: 6,
                                                              blurRadius: 3,
                                                              offset: const Offset(
                                                                  0,
                                                                  1), // changes position of shadow
                                                            ),
                                                          ],
                                                          color: Provider.of<ThemeState>(
                                                                          context)
                                                                      .theme ==
                                                                  ThemeType.DARK
                                                              ? Colors.black87
                                                              : Colors
                                                                  .indigo[900],
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
