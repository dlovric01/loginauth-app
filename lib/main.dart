import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_app/screens/auth_form.dart';
import 'package:login_app/screens/user_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Signin/Login App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
              ).copyWith(
                  secondary: Colors.white, secondaryVariant: Colors.lightBlue),
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return UserScreen();
                }
                return AuthScreen();
              },
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
