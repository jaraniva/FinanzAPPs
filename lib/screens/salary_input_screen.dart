import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class SalaryInputScreen extends StatefulWidget {
  @override
  _SalaryInputScreenState createState() => _SalaryInputScreenState();
}

class _SalaryInputScreenState extends State<SalaryInputScreen> {
  final TextEditingController _salaryController = TextEditingController();

  Future<void> _guardarSalario() async {
    final salaryText = _salaryController.text;
    if (salaryText.isNotEmpty) {
      final nuevoSalario = double.tryParse(salaryText);
      if (nuevoSalario != null && nuevoSalario > 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double salarioAnterior = prefs.getDouble('salario') ?? 0.0;
        double salarioActualizado = salarioAnterior + nuevoSalario;

        await prefs.setDouble('salario', salarioActualizado);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        _mostrarError('Por favor ingrese un monto válido.');
      }
    } else {
      _mostrarError('El campo no puede estar vacío.');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ingrese el monto de su salario mensual',
                style: TextStyle(fontSize: 22, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ejemplo: 500',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarSalario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
