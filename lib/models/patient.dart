class Patient {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String adresse;
  String? motDePasse;
  final String role;

  Patient({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.adresse,
    this.motDePasse,
    this.role = 'Patient',
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      adresse: json['adresse'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'adresse': adresse,
      if (motDePasse != null && motDePasse!.isNotEmpty)
        'motDePasse': motDePasse,
      'role': role,
    };
  }
}
