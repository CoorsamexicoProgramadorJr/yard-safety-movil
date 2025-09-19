import 'package:flutter/material.dart';
import 'package:yardsafety/pantallas/login.dart';




//import 'package:yardsafety/pantallas/login.dart';
//import 'package:yardsafety/pantallas/login.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 2, 85, 249)),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
