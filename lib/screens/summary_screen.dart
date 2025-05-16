import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class SummaryScreen extends StatelessWidget {
  final double salary;
  final double rent;
  final double market;
  final double services;
  final double transport;
  final double education;
  final double savings;

  SummaryScreen({
    required this.salary,
    required this.rent,
    required this.market,
    required this.services,
    required this.transport,
    required this.education,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Arriendo": rent,
      "Mercado": market,
      "Servicios": services,
      "Transporte": transport,
      "Estudios": education,
      "Ahorro": savings < 0 ? 0 : savings,
    };

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Salario mensual: \$${salary.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 22, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                dataMap: dataMap,
                chartType: ChartType.disc,
                chartRadius: MediaQuery.of(context).size.width / 1.5,
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Tu ahorro es de \$${savings.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: savings >= 0 ? Colors.white : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
