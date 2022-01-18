import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static const routeName = "/settings";

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black45,
        title: const Text("Settings screen"),
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
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("Dark mode activated"),
                      ),
                      Switch(
                          value: _dark,
                          onChanged: (value) {
                            setState(() {
                              _dark = value;
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
                      const Center(
                        child: Text("App langugage  "),
                      ),
                      DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            child: Text("English"),
                            value: 1,
                          ),
                          DropdownMenuItem(
                            child: Text("Czech"),
                            value: 2,
                          ),
                          DropdownMenuItem(
                            child: Text("Polska"),
                            value: 3,
                          )
                        ],
                        onChanged: (value) {},
                        value: 1,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [const Text("Change profile picture")],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
