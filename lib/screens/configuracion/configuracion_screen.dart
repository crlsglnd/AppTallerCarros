import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final List<String> _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  void _editarHorarioDia(BuildContext context, String dia) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Configurar $dia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('¿Taller abierto?'),
                value: dia != 'Domingo', // Simulación
                onChanged: (val) {},
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Ingresos Máximos'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Apertura'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Cierre'))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Guardar')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Taller')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dias.length,
        itemBuilder: (context, index) {
          String dia = _dias[index];
          bool isClosed = dia == 'Domingo';
          return Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: isClosed ? Colors.grey : Colors.blue),
              title: Text(dia, style: TextStyle(fontWeight: FontWeight.bold, color: isClosed ? Colors.grey : Colors.black)),
              subtitle: Text(isClosed ? 'Cerrado' : '08:00 - 17:00 • Límite: 5'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editarHorarioDia(context, dia),
              ),
            ),
          );
        },
      ),
    );
  }
}
