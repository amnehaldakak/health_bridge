import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Swich extends StatefulWidget {
  const Swich({super.key});

  @override
  State<Swich> createState() => _SwichState();
}

class _SwichState extends State<Swich> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                context.goNamed('doctor');
              },
              child: Text('Doctor')),
          TextButton(
              onPressed: () {
                context.goNamed('patient');
              },
              child: Text('Patient'))
        ],
      ),
    );
  }
}
