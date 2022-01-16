import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String imageUrl = "";
  String username = "";

  Future<void> getImageUrl() async {
    final id = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    final dat = querySnapshot.docs.firstWhere((element) {
      return element.id == id;
    });
    imageUrl = dat["image_url"];
    username = dat["username"];
    setState(() {});
    //print(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    getImageUrl();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            Text(username),
            SizedBox(
              width: 70,
            ),
          ],
        ),
        actions: [
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
      body: Container(
        height: 500,
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
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) => Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshot.data.docs[index]["image_url"]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                        snapshot.data.docs[index]["username"]),
                                  ),
                                  const SizedBox(
                                    width: 90,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text("now"),
                                  ),
                                ],
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
    );
  }
}
