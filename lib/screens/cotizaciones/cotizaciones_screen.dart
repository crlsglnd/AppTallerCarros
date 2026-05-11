import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class CotizacionesScreen extends StatelessWidget {
  const CotizacionesScreen({super.key});

  void _mostrarDialogoCrearCotizacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Cotización'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'ID del Vehículo'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Costo Mano de Obra'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Repuestos (Detalle):', style: TextStyle(fontWeight: FontWeight.bold)),
                // Simulamos una lista de detalles
                ListTile(
                  title: const Text('Filtro de aceite'),
                  trailing: const Text('\$15.00'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('Aceite 5W-30 (Galón)'),
                  trailing: const Text('\$40.00'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Añadir línea de detalle
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Repuesto'),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Guardar maestro y detalles en Supabase
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAceptarCotizacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedPayment = 'efectivo';
        return StatefulBuilder(
          builder: (context, setState) {
            double manoObra = 50.0;
            double repuestos = 55.0; // 15 + 40
            double recargo = selectedPayment == 'tarjeta' ? repuestos * 0.05 : 0.0;
            double total = manoObra + repuestos + recargo;

            return AlertDialog(
              title: const Text('Aceptar Cotización'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seleccione el método de pago:'),
                  RadioListTile<String>(
                    title: const Text('Efectivo'),
                    value: 'efectivo',
                    groupValue: selectedPayment,
                    onChanged: (val) => setState(() => selectedPayment = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Tarjeta (5% recargo en repuestos)'),
                    value: 'tarjeta',
                    groupValue: selectedPayment,
                    onChanged: (val) => setState(() => selectedPayment = val!),
                  ),
                  const Divider(),
                  Text('Mano de Obra: \$${manoObra.toStringAsFixed(2)}'),
                  Text('Repuestos: \$${repuestos.toStringAsFixed(2)}'),
                  if (recargo > 0)
                    Text('Recargo Tarjeta: \$${recargo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  Text('Total a Pagar: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Actualizar estado y crear Orden de Trabajo vinculada si aplica
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar Aceptación'),
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
      appBar: AppBar(title: const Text('Cotizaciones')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 1, // Simulando 1 registro para ver los botones
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              leading: const Icon(Icons.request_quote, color: Color(0xFF1565C0)),
              title: const Text('Cotización #123 - Vehículo ABC-1234'),
              subtitle: const Text('Total base: \$105.00 - Pendiente'),
              children: [
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detalle de Repuestos:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Filtro de aceite'), Text('\$15.00')],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Aceite 5W-30 (Galón)'), Text('\$40.00')],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mano de Obra', style: TextStyle(fontStyle: FontStyle.italic)),
                          Text('\$50.00'),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Aceptar'),
                        onPressed: () => _mostrarDialogoAceptarCotizacion(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Declinar'),
                        onPressed: () {
                          // TODO: Declinar cotización
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearCotizacion(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
