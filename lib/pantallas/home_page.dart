import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Necesario para SharedPreferences

import 'package:yardsafety/pantallas/reportes_page.dart';
import 'package:yardsafety/pantallas/login.dart'; 
import 'siniestros_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 1;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
  }

  // --- NUEVO MÉTODO PARA CERRAR SESIÓN ---
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Eliminar el token de autenticación
    await prefs.remove('token');
    
    // Opcional: Eliminar el nombre completo si lo guardaste
    await prefs.remove('nombreCompleto'); 

    // 2. Navegar de vuelta a la LoginPage, reemplazando todas las rutas anteriores
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, // Esto asegura que el usuario no pueda volver atrás
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.file_open, color: Color.fromARGB(255, 37, 161, 255)),
          Icon(Icons.warning, color: Color.fromARGB(255, 37, 161, 255)),
          Icon(Icons.logout_sharp, color: Color.fromARGB(255, 37, 161, 255)),
        ],
        inactiveIcons: const [
          Text("Reportes"),
          Text("Siniestros"),
          Text("Log out"),
        ],
        color: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: _tabIndex,
        onTap: (index) {
          if (index == 2) {
            // Si el índice es 2 (Log out), ejecutamos el cierre de sesión
            _logout();
          } else {
            // Para las otras pestañas, cambiamos la página normalmente
            setState(() {
              _tabIndex = index;
              pageController.jumpToPage(_tabIndex);
            });
          }
        },
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),//tamaño de la barra 
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: const Color.fromARGB(255, 190, 190, 190),
        elevation: 10,
      ),
      body: PageView(
        controller: pageController,
        // Eliminamos el manejo de onTap para evitar que el usuario deslice a la página de Logout/cerrar sesión
        // El deslizamiento a las páginas Reportes (0) y Siniestros (1) aún funciona.
        onPageChanged: (v) {
          if (v < 2) { // Solo actualiza el índice si no es la página de logout
            setState(() {
              _tabIndex = v;
            });
          }
        },
        children: const [
          ReportesPage(),
          SiniestrosPage(),
          // Se mantiene un widget de placeholder para el índice 2, aunque el onTap lo manejará
          Center(child: Text("Cerrando sesión...")), 
        ],
      ),
    );
  }
}
