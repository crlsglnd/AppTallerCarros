import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Ingresos')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Header del Calendario
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mayo 2026', // Estático por ahora
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            ),
          ),
          // Grid del Calendario
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
              itemCount: 31, // Días del mes
              itemBuilder: (context, index) {
                int day = index + 1;
                bool isFull = day == 15 || day == 20; // Simulación de días llenos
                bool isSelected = _selectedDate.day == day;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = DateTime(2026, 5, day);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? const Color(0xFF1565C0) 
                        : (isFull ? Colors.red.shade100 : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isFull)
                          const Icon(Icons.circle, size: 8, color: Colors.red),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 32),
          // Detalle del día seleccionado
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles para el ${_selectedDate.day} de Mayo',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedDate.day == 15 || _selectedDate.day == 20) ...[
                    const Text('Estado: LLENO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const ListTile(
                      leading: Icon(Icons.directions_car),
                      title: Text('Vehículo: Toyota Corolla - Placa P-123XYZ'),
                      subtitle: Text('Orden #1024 - Pendiente'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.directions_car),
                      title: Text('Vehículo: Honda Civic - Placa P-456ABC'),
                      subtitle: Text('Orden #1025 - En Progreso'),
                    ),
                  ] else ...[
                    const Text('Disponibilidad: ALTA', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Center(child: Text('No hay ingresos programados para este día.')),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
