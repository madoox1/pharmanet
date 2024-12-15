import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pharmacien.dart';
import 'pharmacien_form_screen.dart'; // Ajout de cet import

class PharmacienListScreen extends StatefulWidget {
  @override
  _PharmacienListScreenState createState() => _PharmacienListScreenState();
}

class _PharmacienListScreenState extends State<PharmacienListScreen> {
  List<Pharmacien> pharmaciens = [];
  bool isLoading = true;
  final String baseUrl =
      'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api';

  @override
  void initState() {
    super.initState();
    fetchPharmaciens();
  }

  Future<void> fetchPharmaciens() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pharmaciens'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          pharmaciens = data.map((json) => Pharmacien.fromJson(json)).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          pharmaciens = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deletePharmacien(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/admin/pharmaciens/$id'));
      if (response.statusCode == 204) {
        setState(() {
          pharmaciens.removeWhere((p) => p.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pharmacien supprimé avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Pharmaciens')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PharmacienFormScreen()),
          );
          if (result == true) fetchPharmaciens();
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pharmaciens.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun pharmacien trouvé',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cliquez sur + pour ajouter un pharmacien',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: pharmaciens.length,
                  itemBuilder: (context, index) {
                    final pharmacien = pharmaciens[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('${pharmacien.prenom} ${pharmacien.nom}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pharmacien.email),
                            if (pharmacien.pharmacie != null)
                              Text('Pharmacie: ${pharmacien.pharmacie!.nom}',
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PharmacienFormScreen(
                                      pharmacien: pharmacien,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  fetchPharmaciens();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Voulez-vous vraiment supprimer ce pharmacien?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deletePharmacien(pharmacien.id!);
                                      },
                                      child: Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
