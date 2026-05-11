import 'package:flutter/material.dart';

class VehiculosScreen extends StatelessWidget {
  const VehiculosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos')),
      body: const Center(child: Text('Pantalla de Vehículos')),
    );
  }
}
