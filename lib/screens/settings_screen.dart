import 'dart:io';

import 'package:chat_app/assets/theme_state.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:chat_app/assets/image_picker.dart' as pick;
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static const routeName = "/settings";

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

String locVal = "";
bool _dark = false;
File _imageFile = File("");

void _pickedImage(File image) {
  _imageFile = image;
}

Future<void> setDarkMode(BuildContext context) async {
  final uId = FirebaseAuth.instance.currentUser!.uid;

  try {
    FirebaseFirestore.instance.collection("users").doc(uId).update({
      "dark": _dark,
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occured')),
    );

    throw (e);
  }

  Provider.of<ThemeState>(context, listen: false).theme =
      _dark ? ThemeType.DARK : ThemeType.LIGHT;
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    locVal = MyApp.of(context)!.getLocale();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black45,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back)),
        title: Text(AppLocalizations.of(context)!.settingsText),
      ),
      body: Container(
        color: Colors.black45,
        child: Container(
            margin: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              color: Provider.of<ThemeState>(context).theme == ThemeType.DARK
                  ? Colors.grey
                  : Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(AppLocalizations.of(context)!.darkMode),
                    ),
                    Switch(
                        value: _dark,
                        onChanged: (value) {
                          setState(() {
                            _dark = value;
                            setDarkMode(context);
                          });
                        })
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child:
                          Text(AppLocalizations.of(context)!.appLang + "   "),
                    ),
                    DropdownButton(
                      items: const [
                        DropdownMenuItem(
                          child: Text("English"),
                          value: "en",
                        ),
                        DropdownMenuItem(
                          child: Text("Čeština"),
                          value: "cs",
                        ),
                        DropdownMenuItem(
                          child: Text("Polska"),
                          value: "pl",
                        )
                      ],
                      onChanged: (value) {
                        switch (value) {
                          case "en":
                            MyApp.of(context)!.setLocale(
                                const Locale.fromSubtags(languageCode: 'en'));
                            locVal = "en";
                            break;
                          case "cs":
                            MyApp.of(context)!.setLocale(
                                const Locale.fromSubtags(languageCode: 'cs'));
                            locVal = "cs";

                            break;
                          case "pl":
                            MyApp.of(context)!.setLocale(
                                const Locale.fromSubtags(languageCode: 'pl'));
                            locVal = "pl";

                            break;
                        }
                        setState(() {});
                      },
                      value: locVal,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(AppLocalizations.of(context)!.changeProPict)],
                ),
                pick.ImagePicker(_pickedImage, false),
              ]),
            )),
      ),
    );
  }
}
