import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_expense_screen.dart';
import 'salary_input_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _salary;
  List<String> _gastos = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _salary = prefs.getDouble('salario') ?? 0.0;
      _gastos = prefs.getStringList('gastos_recientes') ?? [];
    });
  }

  void _goToAddGasto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(),
      ),
    ).then((_) => _loadInitialData());
  }

  void _goToSalaryInput() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalaryInputScreen()),
    ).then((_) => _loadInitialData());
  }

  void _deleteGasto(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gastos.removeAt(index);
      prefs.setStringList('gastos_recientes', _gastos);
    });
  }

  void _editGasto(int index) {
    final gastoOriginal = _gastos[index];
    final partes = gastoOriginal.split(' - ');
    if (partes.length < 3) return;

    final TextEditingController montoController =
    TextEditingController(text: partes[1].replaceAll('\$', ''));
    final TextEditingController descripcionController =
    TextEditingController(text: partes.length > 3 ? partes[3] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Categoría: ${partes[2]}'),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nuevo monto'),
              ),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(labelText: 'Nueva descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                final nuevoMonto = double.tryParse(montoController.text);
                if (nuevoMonto == null || nuevoMonto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Monto inválido')),
                  );
                  return;
                }

                final nuevoGasto =
                    '${partes[0]} - \$${nuevoMonto.toStringAsFixed(2)} - ${partes[2]}'
                    '${descripcionController.text.isNotEmpty ? ' - ${descripcionController.text}' : ''}';

                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  _gastos[index] = nuevoGasto;
                  prefs.setStringList('gastos_recientes', _gastos);
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _irAGrafico() {
    double rent = 0, market = 0, services = 0, transport = 0, education = 0;
    double total = 0;

    for (var gasto in _gastos) {
      final partes = gasto.split(' - ');
      if (partes.length < 3) continue;
      final monto = double.tryParse(partes[1].replaceAll('\$', '')) ?? 0;
      final categoria = partes[2].trim().toLowerCase();

      switch (categoria) {
        case 'arriendo':
          rent += monto;
          break;
        case 'mercado':
          market += monto;
          break;
        case 'servicios':
          services += monto;
          break;
        case 'transporte':
          transport += monto;
          break;
        case 'estudios':
          education += monto;
          break;
      }

      total += monto;
    }

    final savings = (_salary ?? 0) - total;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          salary: _salary ?? 0,
          rent: rent,
          market: market,
          services: services,
          transport: transport,
          education: education,
          savings: savings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FinanzAPPs'),
        backgroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: Icon(Icons.attach_money),
            tooltip: 'Ingresar salario',
            onPressed: _goToSalaryInput,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddGasto,
        backgroundColor: Colors.green.shade800,
        child: Icon(Icons.add),
        tooltip: 'Agregar gasto',
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salario actual: \$${_salary?.toStringAsFixed(2) ?? '0.00'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Últimos gastos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _gastos.isEmpty ? null : _irAGrafico,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              child: Text('Ver gráfico de gastos'),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _gastos.isEmpty
                  ? Center(child: Text('No hay gastos aún'))
                  : ListView.builder(
                itemCount: _gastos.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_gastos[index]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteGasto(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gasto eliminado')),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.money_off),
                        title: Text(_gastos[index]),
                        onTap: () => _editGasto(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
