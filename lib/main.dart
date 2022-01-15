import 'package:chat_app/assets/splash_screen.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
      future: _initialization,
      builder: (ctx, snap) => MaterialApp(
        title: 'ChatApp',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            backgroundColor: Colors.grey,
            fontFamily: "Quicksand"),
        home: snap.connectionState != ConnectionState.done
            ? SplashScreen()
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, snapshot) =>
                    snapshot.hasData ? ChatScreen() : AuthScreen()),
      ),
    );
  }
}
