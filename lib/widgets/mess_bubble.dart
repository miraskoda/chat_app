import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class messBuble extends StatelessWidget {
  const messBuble({
    Key? key,
    required this.email,
    required this.username,
    required this.text,
    required this.isMe,
  }) : super(key: key);

  final String username;
  final String text;

  final bool isMe;
  final String email;

  @override
  Widget build(BuildContext context) {
    //print(isMe);

    return Container(
      child: Column(
        crossAxisAlignment: email == FirebaseAuth.instance.currentUser?.email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.blue,
                    Colors.green,
                  ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(username),
                const SizedBox(
                  width: 20,
                ),
                Text(text),
              ],
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
