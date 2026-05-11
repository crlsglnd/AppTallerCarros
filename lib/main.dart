import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_taller_carros/screens/home_screen.dart';
import 'package:app_taller_carros/screens/clientes/clientes_screen.dart';
import 'package:app_taller_carros/screens/vehiculos/vehiculos_screen.dart';
import 'package:app_taller_carros/screens/ordenes/ordenes_screen.dart';
import 'package:app_taller_carros/screens/cotizaciones/cotizaciones_screen.dart';
import 'package:app_taller_carros/screens/proveedores/proveedores_screen.dart';
import 'package:app_taller_carros/screens/repuestos_referencia/repuestos_referencia_screen.dart';
import 'package:app_taller_carros/screens/calendario/calendario_screen.dart';
import 'package:app_taller_carros/screens/configuracion/configuracion_screen.dart';

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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Gris muy claro
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Azul moderno
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF00ACC1), // Teal/Cyan como acento
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0), // Azul oscuro
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/clientes': (context) => const ClientesScreen(),
        '/vehiculos': (context) => const VehiculosScreen(),
        '/ordenes': (context) => const OrdenesScreen(),
        '/cotizaciones': (context) => const CotizacionesScreen(),
        '/proveedores': (context) => const ProveedoresScreen(),
        '/repuestos_referencia': (context) => const RepuestosReferenciaScreen(),
        '/calendario': (context) => const CalendarioScreen(),
        '/configuracion': (context) => const ConfiguracionScreen(),
      },
    );
  }
}
