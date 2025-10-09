import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:yardsafety/pantallas/reportes_page.dart';

import '../config/app_config.dart'; // Importación corregida

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
          image: DecorationImage(
            image: const AssetImage("assets/images/fondo.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56.0),
            child: Column(
              children: [
                const SizedBox(height:50),
                
                _buildHeader(),

                const SizedBox(height: 100),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildLoginCard(context),
                  ),
                ),

                _buildOtherLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.lock_outline, size: 80, color: Colors.white),
        SizedBox(height: 10),
        Text(
          "Iniciar Sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: SizedBox(
        width: size.width * 0.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Card(
              color: Colors.white.withOpacity(0.2),
              elevation: 0, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Bienvenido a Yard Safety",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInput("Correo electrónico", Icons.email, emailController),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 10),
                    if (_errorMsg != null)
                      Text(
                        _errorMsg!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType:
          hint.toLowerCase().contains("correo") ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white54),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const OutlineInputBorder( 
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white), 
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: _obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        hintText: "Contraseña",
        hintStyle: const TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white54),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Color.fromARGB(255, 137, 172, 218))
            : const Text("Iniciar sesión"),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final url = Uri.parse('${AppConfig.baseUrl}/login');
    final Map<String, String> body = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      print(response);

      // Verificamos si la respuesta es exitosa
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? token = responseBody['token'];
        
        
        final Map<String, dynamic>? userAuth = responseBody['userAuth'];
        // --- FIN DE LA MODIFICACIÓN CLAVE ---

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          
          // 1. Guardar el token de manera segura
          await prefs.setString('token', token);

          // 2. Extraer y guardar el nombre completo
          if (userAuth != null) {
            final String nombre = userAuth['nombre'] ?? '';
            final String apellido = userAuth['apellido'] ?? '';
            final String nombreCompleto = '$nombre $apellido';
            await prefs.setString('nombreCompleto', nombreCompleto.trim());
          }


          if (mounted) {
            // Navegar a la página principal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ReportesPage()), // Navegación corregida
            );
          }
        } else {
          // Si el servidor no devuelve el token
          setState(() {
            _errorMsg = "Error: El servidor no proporcionó un token.";
          });
        }
      } else {
        // Manejar errores como credenciales incorrectas (401)
        setState(() {
          _errorMsg = "Credenciales incorrectas. Inténtalo de nuevo.";
        });
      }
    } catch (e) {
      // Capturar errores de conexión (DNS, no hay internet, etc.)
      setState(() {
        _errorMsg = "Error de conexión. Verifica tu conexión a internet o la URL de la API.";
      });
      print('Error de conexión detallado: $e'); // Imprime el error para depuración
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildOtherLogin() {
    return const Column(
      children: [
        Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.white)),
        
      ],
    );
  }
}
