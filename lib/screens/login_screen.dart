import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_dashboard.dart';
import 'patient_dashboard.dart';
import 'pharmacist_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Vérification des identifiants admin
        if (_emailController.text.trim() == 'admin@admin.com' &&
            _passwordController.text == 'admin123') {
          // Redirection vers le dashboard admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bienvenue Admin!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Si ce n'est pas l'admin, continuer avec l'API pour les autres utilisateurs
        final response = await http.post(
          Uri.parse(
              'http://10.0.2.2:8080/pharmacy-system-backend-1.0-SNAPSHOT/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          Widget dashboard;

          switch (userData['role']) {
            case 'Patient':
              dashboard = PatientDashboard();
              break;
            case 'Pharmacien':
              dashboard = PharmacistDashboard();
              break;
            default:
              throw Exception('Rôle non reconnu');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => dashboard),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bienvenue ${userData['role']}!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Email ou mot de passe incorrect');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60),
                  Hero(
                    tag: 'logo',
                    child: Icon(
                      Icons.local_pharmacy,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'PharmaNet',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value!.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value!.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Mot de passe oublié?'),
                    ),
                  ),
                  SizedBox(height: 24),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
