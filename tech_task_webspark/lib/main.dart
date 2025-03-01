import 'package:flutter/material.dart';
import 'package:tech_task_webspark/provider.dart';
import 'package:tech_task_webspark/start.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MyProvider(),
    child: const MainApp())
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
    );
  }
}
