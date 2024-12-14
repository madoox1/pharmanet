import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pharmacien.dart';
import '../models/pharmacie.dart';

class PharmacienFormScreen extends StatefulWidget {
  final Pharmacien? pharmacien;

  PharmacienFormScreen({this.pharmacien});

  @override
  _PharmacienFormScreenState createState() => _PharmacienFormScreenState();
}

class _PharmacienFormScreenState extends State<PharmacienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  List<Pharmacie> _pharmacies = [];
  Pharmacie? _selectedPharmacie;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pharmacien != null) {
      _nomController.text = widget.pharmacien!.nom;
      _prenomController.text = widget.pharmacien!.prenom;
      _emailController.text = widget.pharmacien!.email;
      _selectedPharmacie = widget.pharmacien!.pharmacie;
    }
    _fetchPharmacies();
  }

  Future<void> _fetchPharmacies() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api/pharmacies'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _pharmacies = data.map((json) => Pharmacie.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching pharmacies: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedPharmacie != null) {
      setState(() => _isLoading = true);

      final pharmacien = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        if (widget.pharmacien == null || _passwordController.text.isNotEmpty)
          'motDePasse': _passwordController.text,
        'role': 'Pharmacien',
        'pharmacie': {'id': _selectedPharmacie!.id},
      };

      try {
        final baseUrl = 'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api';
        final response = widget.pharmacien == null
            ? await http.post(
                Uri.parse('$baseUrl/pharmaciens'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(pharmacien),
              )
            : await http.put(
                Uri.parse('$baseUrl/pharmaciens/${widget.pharmacien!.id}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(pharmacien),
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          throw Exception('Erreur lors de l\'enregistrement');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pharmacien == null ? 'Nouveau Pharmacien' : 'Modifier Pharmacien'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ce champ est requis';
                  if (!value!.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.pharmacien == null
                      ? 'Mot de passe'
                      : 'Nouveau mot de passe (optionnel)',
                ),
                obscureText: true,
                validator: (value) {
                  if (widget.pharmacien == null && (value?.isEmpty ?? true))
                    return 'Ce champ est requis';
                  if (value!.isNotEmpty && value.length < 6)
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<Pharmacie>(
                value: _selectedPharmacie,
                decoration: InputDecoration(labelText: 'Pharmacie'),
                items: _pharmacies.map((pharmacie) {
                  return DropdownMenuItem(
                    value: pharmacie,
                    child: Text(pharmacie.nom),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPharmacie = value);
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une pharmacie' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
