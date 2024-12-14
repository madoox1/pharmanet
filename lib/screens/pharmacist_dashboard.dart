
import 'package:flutter/material.dart';

class PharmacistDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacist Dashboard'),
      ),
      body: Center(
        child: Text('Welcome, Pharmacist!'),
      ),
    );
  }
}