import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso rápido al cliente de Supabase desde cualquier parte de la app.
/// Uso: `supabase.from('clientes').select()`
final supabase = Supabase.instance.client;
