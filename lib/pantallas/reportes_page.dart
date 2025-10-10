import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yardsafety/config/app_config.dart';
import 'package:yardsafety/models/rondas.dart'; 
import 'package:yardsafety/pantallas/login.dart'; 
import '../widgets/ronda_card.dart';
import 'new_report_screen.dart';
import 'package:intl/intl.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:yardsafety/config/pusher_config.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  _ReportesPageState createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  bool _showNewReportScreen = false;
  List<Ronda> _rondas = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedRondaId;
  String _userName = "Usuario";

  late final PusherChannelsClient _pusherClient;
  StreamSubscription<ChannelReadEvent>? _rondasSubscription;

  @override
  void initState() {
    super.initState();
    // Inicializar 'es_ES' para el formato de fecha, si no está globalmente
    Intl.defaultLocale = 'es_ES'; 
    _loadUserData();
    _fetchRondas();
    _initPusher();
  }

  @override
  void dispose() {
    _rondasSubscription?.cancel();
    _pusherClient.disconnect();
    super.dispose();
  }

  Future<void> _initPusher() async {
    PusherChannelsPackageLogger.enableLogs();

    const pusherOptions = PusherChannelsOptions.fromCluster(
      scheme: 'wss',
      cluster: '${PusherConfig.cluster}',
      key: '${PusherConfig.key}',
      port: 443,
    );

    _pusherClient = PusherChannelsClient.websocket(
      options: pusherOptions,
      connectionErrorHandler: (exception, trace, refresh) {
        print("Error de conexión con Pusher: $exception");
        refresh();
      },
    );

    _pusherClient.onConnectionEstablished.listen((_) {

      // 2. SOLO CUANDO la conexión esté lista, nos suscribimos al canal
      final channel = _pusherClient.publicChannel('rondas');
      _rondasSubscription = channel.bind('rondas.updated').listen((event) {

        try {
          if (!mounted) return;

          if (event.data == null || (event.data as String).isEmpty) {
            return;
          }
          final eventData = json.decode(event.data as String) as Map<String, dynamic>;

          final rondaActualizada = Ronda.fromPusherEvent(eventData);

          // La ronda está activa si el status enviado por Pusher es 1
          final esActiva = (eventData['catalogo_ronda_status'] as int? ?? 0) == 1;

          setState(() {
            final index = _rondas.indexWhere((ronda) => ronda.id == rondaActualizada.id);

            if (index != -1) {
                // La ronda existe en la lista
                if (esActiva) {
                    // Si sigue activa, solo se actualiza (ej: cambio de hora o statusRondaId)
                    _rondas[index] = rondaActualizada;
                } else {
                    // Si ya no está activa (Finalizada/Eliminada), se remueve de la lista
                    _rondas.removeAt(index);
                }
            } else if (esActiva) {
                // Nueva ronda activa, se inserta al inicio
                _rondas.insert(0, rondaActualizada);
            }
          });

        } catch (e, stacktrace) {
          print('Error: $e');
          print('Stacktrace: $stacktrace');
        }
      });

      // 3. Confirmamos la suscripción al canal (muy importante)
      channel.subscribe();
    });

    // 4. Finalmente, iniciamos la conexión
    _pusherClient.connect();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? nombre = prefs.getString('nombreCompleto');
    if (mounted) {
      setState(() {
        _userName = nombre ?? 'Usuario';
      });
    }
  }

  Future<void> _fetchRondas() async {
    if (!mounted) return;
    if (_rondas.isEmpty) {
      setState(() => _isLoading = true);
    }
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _error = 'Token de autenticación no encontrado. Redirigiendo...';
        _isLoading = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/rondas"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final resp = json.decode(response.body);
        final List<dynamic> rondasJson = resp['data'];

        if (mounted) {
          setState(() {
            _rondas = rondasJson.map((json) => Ronda.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Error al cargar las rondas. Código de estado: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================
  // MÉTODO PARA CERRAR SESIÓN 
  // ===============================================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('token'); 
    _pusherClient.disconnect();
    
    if (mounted) { 
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (Route<dynamic> route) => false, 
      );
    }
  }

  // ===============================================
  // MÉTODO PARA FINALIZAR UNA RONDA (usa el ID de catálogo de ronda)
  // La actualización de la lista se hará vía Pusher
  // ===============================================
  Future<void> _finalizarRonda(int rondaCatalogoId) async {
    // 1. Muestra diálogo de carga
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Finalizando ronda..."),
              ],
            ),
          );
        },
      );
    }
    
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // cierra diálogo si está abierto
      }
      _logout(); 
      return;
    }

    try {
      // Usamos DELETE como lo definiste para finalizar/eliminar
      final response = await http.delete(
        Uri.parse("${AppConfig.baseUrl}/rondas/$rondaCatalogoId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );
      
      // 2. Cierra diálogo de carga
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Log opcional de éxito
        // print('Ronda $rondaCatalogoId finalizada correctamente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ronda finalizada con éxito.'), backgroundColor: Colors.green),
          );
        }
        // Además de Pusher, forzamos un refresh inmediato para evitar pantalla vacía por latencia
        await _fetchRondas();
      } else {
        String errorMsg = 'Error desconocido al finalizar la ronda.';
        final body = response.body;
        if (body.isNotEmpty) {
          try {
            final errorBody = json.decode(body);
            errorMsg = errorBody['message']?.toString() ?? errorMsg;
          } catch (_) {
            // cuerpo no JSON, usa texto crudo
            errorMsg = body;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMsg'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // asegura cerrar diálogo si hubo excepción
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  void _openNewReportScreen(int rondaId) {
    setState(() {
      _selectedRondaId = rondaId;
      _showNewReportScreen = true;
    });
  }

  void _backToRondas() {
    setState(() {
      _showNewReportScreen = false;
      _selectedRondaId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
    DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'es_ES').format(DateTime.now());

    Widget rondasContent;

    if (_isLoading) {
      rondasContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      rondasContent = Center(
        child: Text(_error ?? 'Ocurrió un error desconocido'),
      );
    } else if (_rondas.isEmpty) {
      rondasContent = const Center(
        child: Text('No hay rondas disponibles.'),
      );
    } else {
      rondasContent = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, $_userName',
                style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Hoy es ${formattedDate.capitalize()}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            const Text('RONDAS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              children: _rondas
                  .map(
                    (r) => RondaCard(
                      ronda: r,
                      // El `onTap` de la tarjeta llama a su lógica interna (navegación o modal)
                      onTap: () {}, 
                      onRefresh: _fetchRondas,
                      // El botón de finalizar es visible si statusRondaId es 2 (Ejecutándose)
                      onFinish: r.statusRondaId == 2
                          ? () => _finalizarRonda(r.id) // usar ID de catálogo
                          : null, 
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 100),
          ],
      ));
    }

    final Widget rondasView = Scaffold(
      appBar: AppBar(
        title: const Text('Rondas Disponibles'),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout, 
          ),
        ],
      ),
      body: rondasContent,
    );


    return IndexedStack(
        index: _showNewReportScreen ? 1 : 0,
        children: [
          rondasView, 
          if (_selectedRondaId != null)
            NewReportScreen( 
              rondaId: _selectedRondaId!,
              onBack: _backToRondas,
            ),
        ],
      );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}