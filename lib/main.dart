import 'dart:convert';

import 'package:chat_app/assets/splash_screen.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/main_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'assets/theme_state.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      .whenComplete(() => runApp(ChangeNotifierProvider<ThemeState>(
            create: (context) => ThemeState(),
            child: const MyApp(),
          )));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  Future<void> getDarkMode(BuildContext context) async {
    final uId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final userData =
          await FirebaseFirestore.instance.collection("users").doc(uId).get();

      _darkMode = userData["dark"] as bool;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occured')),
      );

      throw (e);
    }
  }

  Locale _locale = const Locale("en", "");

  String getLocale() {
    return _locale.languageCode;
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Future<void> firebaseMess(String text) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const String serverToken =
        'AAAAZCOZA2E:APA91bH8YjyzQJ1N0oEuaYclgmDeAbAroSPXA9W92Xfcs5cHVIZKBhcDcXvLDIlsO3IOgDTgufsi93Lq2uwZYMql3215AEf8kjpflEeVfAHa8arYt5BqRAUfbix9wHhXnZQdGCkJk02O';
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': text,
            'title': 'New Message!'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': await messaging.getToken(),
        },
      ),
    );

    print(messaging.getToken().toString());
  }

  @override
  Widget build(BuildContext context) {
    firebaseMess("textooos");
    getDarkMode(context);
    print("darkmodeee " + _darkMode.toString());
    print(context.size!.height);

    return MaterialApp(
      title: 'ChatApp',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("cs", ""),
        Locale("en", ""),
        Locale("pl", ""),
      ],
      locale: _locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "Quicksand",
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: Provider.of<ThemeState>(context).theme == ThemeType.DARK
          ? ThemeMode.dark
          : ThemeMode.light,
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
