import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yardsafety/pantallas/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// main
void main() async {
  // Asegurarse de que los widgets están inicializados
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  
  // Inicializa los datos de formato para el español
  await initializeDateFormatting('es', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yard Safety App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 2, 85, 249)),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
