import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/orden_trabajo.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  DateTime _currentMonth = DateTime.now();

  final List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  void _mostrarDetallesDia(DateTime date, List<OrdenTrabajo> ordenes) {
    final ordenesDelDia = ordenes.where((o) => 
      o.fechaIngreso != null &&
      o.fechaIngreso!.year == date.year && 
      o.fechaIngreso!.month == date.month && 
      o.fechaIngreso!.day == date.day
    ).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles para el ${date.day} de ${_meses[date.month - 1]}'),
          content: SizedBox(
            width: 400,
            child: ordenesDelDia.isEmpty 
              ? const Text('No hay ingresos programados para este día.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ordenesDelDia.map((o) => ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text('Orden #${o.id?.substring(0,5) ?? 'N/A'}'),
                    subtitle: Text('Estado: ${o.estado}'),
                  )).toList(),
                ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Ingresos')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<OrdenTrabajo>>(
        future: _supabaseService.getOrdenes(),
        builder: (context, snapshot) {
          final ordenes = snapshot.data ?? [];
          
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_meses[_currentMonth.month - 1]} ${_currentMonth.year}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                      final count = ordenes.where((o) => 
                        o.fechaIngreso != null &&
                        o.fechaIngreso!.year == date.year && 
                        o.fechaIngreso!.month == date.month && 
                        o.fechaIngreso!.day == date.day
                      ).length;
                      
                      bool isFull = count >= 5;

                      return InkWell(
                        onTap: () => _mostrarDetallesDia(date, ordenes),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFull ? Colors.red.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$day', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (count > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isFull ? Colors.red : Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
