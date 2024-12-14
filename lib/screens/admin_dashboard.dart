import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pharmacie_list_screen.dart'; // Ajout de l'import

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final String baseUrl =
      'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api';
  Map<String, int> counts = {
    'patients': 0,
    'pharmaciens': 0,
    'pharmacies': 0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/patients/count')),
        http.get(Uri.parse('$baseUrl/pharmaciens/count')),
        http.get(Uri.parse('$baseUrl/pharmacies/count')),
      ]);

      if (responses.every((response) => response.statusCode == 200)) {
        setState(() {
          counts['patients'] = int.parse(responses[0].body);
          counts['pharmaciens'] = int.parse(responses[1].body);
          counts['pharmacies'] = int.parse(responses[2].body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching counts: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildCountCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Column(
                  children: [
                    // Compteurs
                    Row(
                      children: [
                        Expanded(
                          child: _buildCountCard(
                            'Patients',
                            counts['patients']!,
                            Icons.people,
                          ),
                        ),
                        Expanded(
                          child: _buildCountCard(
                            'Pharmaciens',
                            counts['pharmaciens']!,
                            Icons.medical_services,
                          ),
                        ),
                        Expanded(
                          child: _buildCountCard(
                            'Pharmacies',
                            counts['pharmacies']!,
                            Icons.local_pharmacy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    // Boutons de gestion
                    _buildManagementButton(
                      'Gestion des Patients',
                      Icons.people,
                      () {
                        // TODO: Navigation vers la gestion des patients
                      },
                    ),
                    SizedBox(height: 16),
                    _buildManagementButton(
                      'Gestion des Pharmaciens',
                      Icons.medical_services,
                      () {
                        // TODO: Navigation vers la gestion des pharmaciens
                      },
                    ),
                    SizedBox(height: 16),
                    _buildManagementButton(
                      'Gestion des Pharmacies',
                      Icons.local_pharmacy,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PharmacieListScreen(),
                          ),
                        ).then((_) =>
                            fetchCounts()); // Rafraîchir les compteurs au retour
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
