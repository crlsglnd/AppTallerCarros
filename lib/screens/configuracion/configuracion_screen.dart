import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/configuracion_taller.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  final _capacidadController = TextEditingController();
  final _aperturaController = TextEditingController();
  final _cierreController = TextEditingController();

  void _editarHorarioDia(BuildContext context, ConfiguracionTaller config) {
    _capacidadController.text = config.maxIngresosDiarios.toString();
    _aperturaController.text = config.horaApertura;
    _cierreController.text = config.horaCierre;
    bool estaAbierto = config.estaAbierto;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Configurar ${config.diaSemana}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('¿Taller abierto?'),
                      value: estaAbierto,
                      onChanged: (val) => setDialogState(() => estaAbierto = val),
                    ),
                    TextField(
                      controller: _capacidadController,
                      decoration: const InputDecoration(labelText: 'Ingresos Máximos'),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _aperturaController, decoration: const InputDecoration(labelText: 'Apertura (HH:MM)'))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _cierreController, decoration: const InputDecoration(labelText: 'Cierre (HH:MM)'))),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final updatedConfig = ConfiguracionTaller(
                        id: config.id,
                        diaSemana: config.diaSemana,
                        maxIngresosDiarios: int.tryParse(_capacidadController.text) ?? 5,
                        horaApertura: _aperturaController.text,
                        horaCierre: _cierreController.text,
                        estaAbierto: estaAbierto,
                      );
                      await _supabaseService.updateConfiguracionDia(updatedConfig);
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuración actualizada'), backgroundColor: Colors.green),
                      );
                      setState(() {});
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Taller')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<ConfiguracionTaller>>(
        future: _supabaseService.getConfiguracion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          return Column(
            children: [
              // Banner de depuración de conexión
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: snapshot.hasError ? Colors.red : Colors.green,
                child: Text(
                  snapshot.hasError ? 'OFFLINE' : 'ONLINE',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12, 
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              if (snapshot.hasError) 
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Asegúrate de que el archivo .env tenga las llaves correctas y esté en la carpeta de activos.', textAlign: TextAlign.center),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: (snapshot.data ?? []).length,
                  itemBuilder: (context, index) {
                    final config = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: config.estaAbierto ? Colors.blue : Colors.grey),
                        title: Text(config.diaSemana, style: TextStyle(fontWeight: FontWeight.bold, color: config.estaAbierto ? Colors.black : Colors.grey)),
                        subtitle: Text(config.estaAbierto 
                          ? '${config.horaApertura} - ${config.horaCierre} • Límite: ${config.maxIngresosDiarios}'
                          : 'Cerrado'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editarHorarioDia(context, config),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
