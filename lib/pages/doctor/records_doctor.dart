import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';

class RecordsDoctor extends StatefulWidget {
  const RecordsDoctor({super.key});

  @override
  State<RecordsDoctor> createState() => _RecordsDoctorState();
}

class _RecordsDoctorState extends State<RecordsDoctor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('add_record');
        },
        child: Icon(
          Icons.add,
          weight: 3,
          color: blue5,
        ),
      ),
      body: Column(),
    );
  }
}
