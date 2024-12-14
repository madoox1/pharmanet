import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/patient.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  PatientFormScreen({this.patient});

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nomController.text = widget.patient!.nom;
      _prenomController.text = widget.patient!.prenom;
      _emailController.text = widget.patient!.email;
      _adresseController.text = widget.patient!.adresse;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final patient = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        // N'inclure l'email que s'il a été modifié
        if (_emailController.text != widget.patient?.email || widget.patient == null)
          'email': _emailController.text,
        'adresse': _adresseController.text,
        if (widget.patient == null || _passwordController.text.isNotEmpty)
          'motDePasse': _passwordController.text,
        'role': 'Patient',
      };

      try {
        final baseUrl = 'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api';
        final response = widget.patient == null
            ? await http.post(
                Uri.parse('$baseUrl/patients'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(patient),
              )
            : await http.put(
                Uri.parse('$baseUrl/patients/${widget.patient!.id}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(patient),
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.patient == null 
                ? 'Patient ajouté avec succès' 
                : 'Patient modifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Erreur lors de l\'enregistrement');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Nouveau Patient' : 'Modifier Patient'),
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
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ce champ est requis';
                  if (!value!.contains('@')) return 'Email invalide';
                  return null;
                },
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
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.patient == null
                      ? 'Mot de passe'
                      : 'Nouveau mot de passe (optionnel)',
                ),
                obscureText: true,
                validator: (value) {
                  if (widget.patient == null && (value?.isEmpty ?? true))
                    return 'Ce champ est requis';
                  if (value!.isNotEmpty && value.length < 6)
                    return 'Le mot de passe doit contenir au moins 6 caractères';
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
