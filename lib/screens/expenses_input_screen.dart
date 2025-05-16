import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzapps/screens/summary_screen.dart';

class ExpensesInputScreen extends StatefulWidget {
  final double salary;

  const ExpensesInputScreen({Key? key, required this.salary}) : super(key: key);

  @override
  _ExpensesInputScreenState createState() => _ExpensesInputScreenState();
}

class _ExpensesInputScreenState extends State<ExpensesInputScreen> {
  // Controladores de texto para cada campo de gasto
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _marketController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _transportController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedExpenses(); // Cargar valores guardados (si los hay) al iniciar
  }

  // Carga los valores de gastos previamente guardados usando SharedPreferences
  Future<void> _loadSavedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rentController.text = (prefs.getDouble('rent') ?? 0).toString();
      _marketController.text = (prefs.getDouble('market') ?? 0).toString();
      _servicesController.text = (prefs.getDouble('services') ?? 0).toString();
      _transportController.text = (prefs.getDouble('transport') ?? 0).toString();
      _educationController.text = (prefs.getDouble('education') ?? 0).toString();
    });
  }

  // Guarda los valores de gastos en SharedPreferences
  Future<void> _saveExpenses(double rent, double market, double services, double transport, double education) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rent', rent);
    await prefs.setDouble('market', market);
    await prefs.setDouble('services', services);
    await prefs.setDouble('transport', transport);
    await prefs.setDouble('education', education);
  }

  // Muestra una alerta si la suma de gastos excede el salario disponible
  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Presupuesto excedido'),
          content: Text('La suma de los gastos supera el salario ingresado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Valida los datos y navega a la pantalla de resumen (SummaryScreen)
  void _generateSummary() {
    // Convertir los textos de los campos a números (double)
    double rent = double.tryParse(_rentController.text) ?? 0;
    double market = double.tryParse(_marketController.text) ?? 0;
    double services = double.tryParse(_servicesController.text) ?? 0;
    double transport = double.tryParse(_transportController.text) ?? 0;
    double education = double.tryParse(_educationController.text) ?? 0;

    // Calcular el total de gastos
    double totalExpenses = rent + market + services + transport + education;

    // Verificar que el total de gastos no supere el salario
    if (totalExpenses > widget.salary) {
      _showAlert();
      return; // Detener aquí si los gastos exceden el salario
    }

    // Calcular el ahorro (saldo restante del salario luego de los gastos)
    double savings = widget.salary - totalExpenses;

    // Guardar los gastos en las preferencias para futuros usos
    _saveExpenses(rent, market, services, transport, education);

    // Navegar a SummaryScreen pasando todos los datos necesarios
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
          salary: widget.salary,
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
  void dispose() {
    // Liberar los controladores de texto para prevenir fugas de memoria
    _rentController.dispose();
    _marketController.dispose();
    _servicesController.dispose();
    _transportController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título de la pantalla
      appBar: AppBar(
        title: Text('Ingresar Gastos'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        // Fondo con degradado de verde claro a verde oscuro
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightGreen.shade300,
              Colors.green.shade800,
            ],
          ),
        ),
        constraints: BoxConstraints.expand(), // Ocupa toda la pantalla disponible
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Campo de texto para Arriendo (alquiler) con ícono de casa
            TextField(
              controller: _rentController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Arriendo',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo de texto para Mercado (compras de supermercado) con ícono de carrito
            TextField(
              controller: _marketController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Mercado',
                prefixIcon: Icon(Icons.shopping_cart),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo de texto para Servicios (electricidad, agua, etc.) con ícono de recibo
            TextField(
              controller: _servicesController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Servicios',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo de texto para Transporte (gastos de transporte) con ícono de automóvil
            TextField(
              controller: _transportController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Transporte',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo de texto para Estudios (educación) con ícono de escuela
            TextField(
              controller: _educationController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Estudios',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32.0),
            // Botón para generar el presupuesto y pasar a la siguiente pantalla
            ElevatedButton(
              onPressed: _generateSummary,
              child: Text('Generar Presupuesto'),
            ),
          ],
        ),
      ),
    );
  }
}
