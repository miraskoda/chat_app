import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class messBuble extends StatelessWidget {
  const messBuble({
    Key? key,
    required this.username,
    required this.text,
    required this.isMe,
    required this.userId,
  }) : super(key: key);

  final String username;
  final String text;
  final bool isMe;
  final String userId;

  Future<QueryDocumentSnapshot> getImageUrl() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await _collectionRef.get(const GetOptions(source: Source.server));
    return querySnapshot.docs.firstWhere((element) {
      return element.id == userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    getImageUrl();

    return Container(
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            child: Container(
              child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  isMe
                      ? Container()
                      : FutureBuilder(
                          future: getImageUrl(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            return CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!["image_url"]),
                            );
                          },
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(20),
                          topLeft: const Radius.circular(20),
                          bottomLeft: isMe
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                          bottomRight: isMe
                              ? const Radius.circular(0)
                              : const Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  !isMe
                      ? Container()
                      : FutureBuilder(
                          future: getImageUrl(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            return CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!["image_url"]),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
