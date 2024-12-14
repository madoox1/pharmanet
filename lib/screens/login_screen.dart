import 'package:flutter/material.dart';
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

  // Identifiants statiques
  final Map<String, Map<String, dynamic>> _staticUsers = {
    'admin@admin.com': {
      'password': 'admin123',
      'type': 'admin',
      'dashboard': AdminDashboard(),
    },
    'patient@test.com': {
      'password': 'patient123',
      'type': 'patient',
      'dashboard': PatientDashboard(),
    },
    'pharmacist@test.com': {
      'password': 'pharma123',
      'type': 'pharmacist',
      'dashboard': PharmacistDashboard(),
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(Duration(seconds: 1));

      final userEmail = _emailController.text.trim();
      final userPassword = _passwordController.text;

      if (_staticUsers.containsKey(userEmail) &&
          _staticUsers[userEmail]!['password'] == userPassword) {
        // Navigation vers le dashboard correspondant
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _staticUsers[userEmail]!['dashboard'],
          ),
        );

        // Message de bienvenue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenue ${_staticUsers[userEmail]!['type']}!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email ou mot de passe incorrect'),
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
