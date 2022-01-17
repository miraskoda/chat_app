import 'package:chat_app/assets/splash_screen.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/main_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().whenComplete(() => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> firebaseMess() async {
    print("insidee");
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    messaging
        .subscribeToTopic("chat")
        .whenComplete(() => print("completed topic"));

    print('User granted permission: ${settings.authorizationStatus}');
  }

  @override
  Widget build(BuildContext context) {
    firebaseMess();

    return MaterialApp(
      title: 'ChatApp',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.grey,
          fontFamily: "Quicksand"),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) =>
              snapshot.hasData ? MainScreen() : AuthScreen()),
      routes: {
        ChatScreen.routeName: (ctx) => const ChatScreen(),
        SettingsScreen.routeName: (ctx) => const SettingsScreen(),
      },
    );
  }
}
