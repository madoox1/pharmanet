import 'pharmacie.dart';

class Pharmacien {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String? motDePasse;
  final String role;
  final Pharmacie? pharmacie;

  Pharmacien({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.motDePasse,
    this.role = 'Pharmacien',
    this.pharmacie,
  });

  factory Pharmacien.fromJson(Map<String, dynamic> json) {
    return Pharmacien(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      pharmacie: json['pharmacie'] != null ? Pharmacie.fromJson(json['pharmacie']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      if (motDePasse != null) 'motDePasse': motDePasse,
      'role': role,
      if (pharmacie != null) 'pharmacie': {'id': pharmacie!.id},
    };
  }
}
