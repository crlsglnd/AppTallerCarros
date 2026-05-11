import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_taller_carros/screens/home_screen.dart';
import 'package:app_taller_carros/screens/clientes/clientes_screen.dart';
import 'package:app_taller_carros/screens/vehiculos/vehiculos_screen.dart';
import 'package:app_taller_carros/screens/ordenes/ordenes_screen.dart';
import 'package:app_taller_carros/screens/inventario/inventario_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller de Carros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/clientes': (context) => const ClientesScreen(),
        '/vehiculos': (context) => const VehiculosScreen(),
        '/ordenes': (context) => const OrdenesScreen(),
        '/inventario': (context) => const InventarioScreen(),
      },
    );
  }
}
