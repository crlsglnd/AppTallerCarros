import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/cliente.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _searchController = TextEditingController();
  
  List<Cliente> _allClientes = [];
  List<Cliente> _filteredClientes = [];
  bool _isLoading = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterClientes);
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _connectionError = null; });
      final data = await _supabaseService.getClientes();
      setState(() {
        _allClientes = data;
        _filteredClientes = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _connectionError = e.toString(); });
    }
  }

  void _filterClientes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClientes = _allClientes.where((c) {
        return c.nombre.toLowerCase().contains(query) || 
               c.id.toLowerCase().contains(query) ||
               (c.telefono?.contains(query) ?? false);
      }).toList();
    });
  }

  void _mostrarDialogoCliente({Cliente? cliente}) {
    if (cliente != null) {
      _idController.text = cliente.id;
      _nombreController.text = cliente.nombre;
      _emailController.text = cliente.email ?? '';
      _telefonoController.text = cliente.telefono ?? '';
    } else {
      _limpiarControllers();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cliente == null ? 'Nuevo Cliente' : 'Editar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'Identidad (DNI)'),
                  enabled: cliente == null, // ID no se edita usualmente
                ),
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (_idController.text.isNotEmpty && _nombreController.text.isNotEmpty) {
                  try {
                    final c = Cliente(
                      id: _idController.text,
                      nombre: _nombreController.text,
                      email: _emailController.text,
                      telefono: _telefonoController.text,
                    );
                    if (cliente == null) {
                      await _supabaseService.insertCliente(c);
                    } else {
                      await _supabaseService.updateCliente(c);
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(cliente == null ? 'Cliente creado' : 'Cliente actualizado'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminar(Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a ${cliente.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteCliente(cliente.id);
                if (!mounted) return;
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _limpiarControllers() {
    _idController.clear();
    _nombreController.clear();
    _emailController.clear();
    _telefonoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Banner de Conexión
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: _connectionError == null ? Colors.green : Colors.red,
            child: Text(
              _connectionError == null ? 'ONLINE' : 'OFFLINE',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredClientes.isEmpty 
                ? const Center(child: Text('No se encontraron clientes.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _filteredClientes.length,
                    itemBuilder: (context, index) {
                      final c = _filteredClientes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('ID: ${c.id} • ${c.telefono ?? 'Sin tel.'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoCliente(cliente: c)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(c)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCliente(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
