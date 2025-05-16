import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Asegúrate que esta ruta sea correcta

void main() {
  runApp(FinanzApps());
}

class FinanzApps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanzAPPs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(), // Pantalla inicial
    );
  }
}
