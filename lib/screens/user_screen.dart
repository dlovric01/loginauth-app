import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  @override
  State<UserScreen> createState() => _UserScreenState();
}

String username = '';
String email = '';
String password = '';
String? user = '';

var db = FirebaseFirestore.instance;

Future<void> dataBase() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    await db
        .collection('users')
        .doc(currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      username = documentSnapshot['username'];
      user = username;
    });
  } catch (e) {
    print(e);
  }
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About you'),
        actions: [
          TextButton.icon(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          )
        ],
      ),
      body: FutureBuilder(
          future: dataBase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              // here only return is missing
              child: Text(
                'Welcome ' + user!,
                style: TextStyle(fontSize: 30),
              ),
            );
          }),
    );
  }
}
