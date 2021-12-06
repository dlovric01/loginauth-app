import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _login = true;
  String _username = '';
  String _email = '';
  String _password = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  UserCredential? userCredential;

  final _formKey = GlobalKey<FormState>();

  void _userSubmit() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });
        if (!_login) {
          userCredential = await _auth
              .signInWithEmailAndPassword(
            email: _email,
            password: _password,
          )
              .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Enter valid email or password')));
            setState(() {
              _isLoading = false;
            });
          });
        } else {
          userCredential = await _auth
              .createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          )
              .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                content: Text(
                  'Try different email adress',
                  style: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontWeight: FontWeight.bold),
                )));
            setState(() {
              _isLoading = false;
            });
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential!.user!.uid)
              .set({
            'username': _username,
            'email': _email,
            'password': _password,
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          margin: EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Authentication',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    if (_login)
                      TextFormField(
                        key: ValueKey('username'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter username.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                        onSaved: (value) {
                          _username = value!;
                        },
                      ),
                    TextFormField(
                      key: ValueKey('email'),
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter an email address.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      key: ValueKey('password'),
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !value.contains(
                              RegExp(r'[a-zA-Z0-9]'),
                            )) {
                          return 'Please enter password.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (!_isLoading)
                      TextButton(
                        style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.secondaryVariant),
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary)),
                        child: _login
                            ? Text(
                                'Signup',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                        onPressed: () {
                          _userSubmit();
                        },
                      ),
                    if (!_isLoading)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _login = !_login;
                            });
                          },
                          child: Text(_login
                              ? 'I already have an account'
                              : 'Create a new account'),
                        ),
                      ),
                    if (_isLoading) CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showSnakeBar(BuildContext context, String s) {}
}
