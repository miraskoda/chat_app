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

  final _auth = FirebaseAuth.instance;

  bool isRegistering = false;

  late AnimationController _controller;
  late Animation<double> _animation;
  double animValue = 1.0;

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
    try {
      if (isRegistering) {
        await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      }
    } catch (error) {
      print(error);
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
            child: AnimatedContainer(
              height: isRegistering ? 450 : 350,
              decoration: BoxDecoration(
                  // color: Colors.white,
                  //border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 15,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
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
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                          if (isRegistering)
                            FadeTransition(
                              opacity: _animation,
                              child: TextFormField(
                                key: Key("username"),
                                onSaved: (newValue) {
                                  _username = newValue!;
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
                              _email = newValue!;
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
                              _password = newValue!;
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
                                  _formKey.currentState!.save();
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Logging in')),
                                    );

                                    submitForm();
                                    print(_username);
                                    print(_email);
                                    print(_password);
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
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(fontSize: 12),
                                  ))
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
    );
  }
}
