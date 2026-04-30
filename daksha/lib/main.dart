import 'package:flutter/material.dart';

void main() {
  runApp(const DakshaApp());
}

class DakshaApp extends StatelessWidget {
  const DakshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Daksha',
      home: Scaffold(
        body: Center(child: Text('Daksha')),
      ),
    );
  }
}
