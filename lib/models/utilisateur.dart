class Utilisateur {
  int? idUtl;
  String nom;
  String prenom;
  String email;
  String motDePasse;
  String telphone;
  String role;
  String satut;

  Utilisateur({
    this.idUtl,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.telphone,
    required this.role,
    required this.satut,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur': idUtl,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe': motDePasse,
      'telphone': telphone,
      'role': role,
      'satut': satut,
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      idUtl: map['id_utilisateur'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      telphone: map['telphone'],
      role: map['role'],
      satut: map['satut'],
    );
  }
}
