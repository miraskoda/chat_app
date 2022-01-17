import 'dart:io';

import 'package:chat_app/assets/image_picker.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String _username = "";
  String _password = "";
  String _email = "";
  File _imageFile = File("");

  final _auth = FirebaseAuth.instance;

  bool isRegistering = false;

  late AnimationController _controller;
  late Animation<double> _animation;
  double animValue = 1.0;

  void _pickedImage(File image) {
    _imageFile = image;
  }

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void submitForm() async {
    UserCredential _authResult;
    try {
      if (isRegistering) {
        _authResult = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        _authResult = await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child("user_images")
          .child(_authResult.user!.uid + ".jpg");

      await ref.putFile(_imageFile);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(_authResult.user!.uid)
          .set({
        "username": _username,
        "email": _email,
        "image_url": url,
        "uId": _authResult.user!.uid
      });
    } catch (error) {
      throw error;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    void registerNew() {
      isRegistering = !isRegistering;
      setState(() {});
    }

    return Scaffold(
      //backgroundColor: Colors.lightBlue[50],
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/main.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: AnimatedContainer(
                height: isRegistering ? 550 : 350,
                decoration: BoxDecoration(
                    // color: Colors.white,
                    //border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        spreadRadius: 15,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ]),
                duration: const Duration(milliseconds: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Login screen",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (isRegistering) img.ImagePicker(_pickedImage),
                            if (isRegistering)
                              FadeTransition(
                                opacity: _animation,
                                child: TextFormField(
                                  key: Key("username"),
                                  onSaved: (newValue) {
                                    _username = newValue!.trim();
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Username',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a valid username";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            if (isRegistering)
                              const SizedBox(
                                height: 10,
                              ),
                            TextFormField(
                              key: Key("email"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _email = newValue!.trim();
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              key: Key("pass"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a valid password";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _password = newValue!.trim();
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Password',
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black, // background
                                  ),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();

                                    _formKey.currentState!.save();
                                    if (_formKey.currentState!.validate() &&
                                        _imageFile.path.isNotEmpty) {
                                      print(_imageFile.path.isNotEmpty);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Logging in')),
                                      );
                                      submitForm();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('An error occured')),
                                      );
                                    }
                                  },
                                  child: const Text("    Submit    "),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black, // background
                                  ),
                                  onPressed: () {
                                    registerNew();

                                    setState(() {
                                      animValue = animValue == 1 ? 0 : 1;
                                      if (animValue == 0) {
                                        _controller.animateTo(1.0);
                                      } else {
                                        _controller.animateBack(0.0);
                                      }
                                    });
                                  },
                                  child: isRegistering
                                      ? const Text(
                                          "Back to login",
                                          style: TextStyle(fontSize: 12),
                                        )
                                      : const Text(
                                          "Register",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
