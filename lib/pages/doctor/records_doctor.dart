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
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              context.goNamed('patient_state');
            },
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 2,
              shadowColor: blue3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'اسم المريض',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.goNamed('patient_state');
            },
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 2,
              shadowColor: blue3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'اسم المريض',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
