import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    //getImageUrl();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                                  Container(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          //print(snapshot.data.docs);
                                          Navigator.of(context).pushNamed(
                                            ChatScreen.routeName,
                                            arguments: snapshot.data.docs[index]
                                                ["uId"],
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot.data.docs[index]
                                                      ["image_url"]),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text(snapshot.data
                                                  .docs[index]["username"]),
                                            ),
                                            const SizedBox(
                                              width: 90,
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10.0),
                                              child: Text("now"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
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
