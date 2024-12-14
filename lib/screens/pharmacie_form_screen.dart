import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pharmacie.dart';

class PharmacieFormScreen extends StatefulWidget {
  final Pharmacie? pharmacie;

  PharmacieFormScreen({this.pharmacie});

  @override
  _PharmacieFormScreenState createState() => _PharmacieFormScreenState();
}

class _PharmacieFormScreenState extends State<PharmacieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pharmacie != null) {
      _nomController.text = widget.pharmacie!.nom;
      _adresseController.text = widget.pharmacie!.adresse;
      _latitudeController.text = widget.pharmacie!.latitude.toString();
      _longitudeController.text = widget.pharmacie!.longitude.toString();
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final pharmacie = {
        'nom': _nomController.text,
        'adresse': _adresseController.text,
        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
      };

      try {
        final baseUrl = 'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api';
        final response = widget.pharmacie == null
            ? await http.post(
                Uri.parse('$baseUrl/pharmacies'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(pharmacie),
              )
            : await http.put(
                Uri.parse('$baseUrl/pharmacies/${widget.pharmacie!.id}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(pharmacie),
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
        title: Text(widget.pharmacie == null ? 'Nouvelle Pharmacie' : 'Modifier Pharmacie'),
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
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ce champ est requis';
                  final latitude = double.tryParse(value!);
                  if (latitude == null) return 'Valeur invalide';
                  if (latitude < -90 || latitude > 90) 
                    return 'La latitude doit être entre -90 et 90';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ce champ est requis';
                  final longitude = double.tryParse(value!);
                  if (longitude == null) return 'Valeur invalide';
                  if (longitude < -180 || longitude > 180) 
                    return 'La longitude doit être entre -180 et 180';
                  return null;
                },
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
