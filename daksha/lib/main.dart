import 'package:flutter/material.dart';
import 'core/theme.dart';

void main() {
  runApp(const DakshaApp());
}

class DakshaApp extends StatelessWidget {
  const DakshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daksha',
      debugShowCheckedModeBanner: false,
      theme: buildDakshaTheme(),
      home: const Scaffold(
        body: Center(child: Text('Daksha')),
      ),
    );
  }
}
