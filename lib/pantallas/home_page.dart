import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:yardsafety/pantallas/reportes_page.dart';


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
          setState(() {
            _tabIndex = index;
            pageController.jumpToPage(_tabIndex);
          });
        },
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),//tamaño de la barra 
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Color.fromARGB(255, 190, 190, 190),
        elevation: 10,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          setState(() {
            _tabIndex = v;
          });
        },
        children: const [
          ReportesPage(),
          SiniestrosPage(),
          Center(child: Text("Logout")), 
        
        ],
      ),
    );
  }
}
