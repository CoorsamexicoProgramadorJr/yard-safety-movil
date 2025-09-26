import 'package:flutter/material.dart';
import 'package:yardsafety/pantallas/login.dart';
import 'package:intl/date_symbol_data_local.dart';

// main
void main() async {
  // Asegurarse de que los widgets están inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
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
