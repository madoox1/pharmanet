class Pharmacie {
  final int? id;
  final String nom;
  final String adresse;
  final String status;
  final double latitude;
  final double longitude;

  Pharmacie({
    this.id,
    required this.nom,
    required this.adresse,
    this.status = 'Inactive',
    required this.latitude,
    required this.longitude,
  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    return Pharmacie(
      id: json['id'],
      nom: json['nom'],
      adresse: json['adresse'],
      status: json['status'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'adresse': adresse,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
