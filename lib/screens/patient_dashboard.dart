
import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
      ),
      body: Center(
        child: Text('Welcome, Patient!'),
      ),
    );
  }
}