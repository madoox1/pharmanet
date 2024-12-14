import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pharmacie.dart';
import 'pharmacie_form_screen.dart';

class PharmacieListScreen extends StatefulWidget {
  @override
  _PharmacieListScreenState createState() => _PharmacieListScreenState();
}

class _PharmacieListScreenState extends State<PharmacieListScreen> {
  List<Pharmacie> pharmacies = [];
  bool isLoading = true;
  final String baseUrl =
      'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api';

  @override
  void initState() {
    super.initState();
    fetchPharmacies();
  }

  Future<void> fetchPharmacies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pharmacies'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          pharmacies = data.map((json) => Pharmacie.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des pharmacies')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> deletePharmacy(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/pharmacies/$id'));
      if (response.statusCode == 204) {
        setState(() {
          pharmacies.removeWhere((pharmacy) => pharmacy.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pharmacie supprimée avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      final response =
          await http.put(Uri.parse('$baseUrl/pharmacies/$id/status'));
      if (response.statusCode == 200) {
        await fetchPharmacies();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du changement de status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Pharmacies'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PharmacieFormScreen()),
          );
          if (result == true) {
            fetchPharmacies();
          }
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pharmacies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pharmacy_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune pharmacie trouvée',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cliquez sur + pour ajouter une pharmacie',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacie = pharmacies[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(pharmacie.nom),
                        subtitle: Text(pharmacie.adresse),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                pharmacie.status == 'Active'
                                    ? Icons.toggle_on
                                    : Icons.toggle_off,
                                color: pharmacie.status == 'Active'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () => toggleStatus(pharmacie.id!),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PharmacieFormScreen(
                                      pharmacie: pharmacie,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  fetchPharmacies();
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
                                      'Voulez-vous vraiment supprimer cette pharmacie?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deletePharmacy(pharmacie.id!);
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
