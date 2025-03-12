class Panne {
  final int? id;
  final int idReclamation;
  final int? idTechnicien;
  final String description;
  final DateTime dateDetection;
  final DateTime? dateResolution;
  final String statut;
  
  Panne({
    this.id,
    required this.idReclamation,
    this.idTechnicien,
    required this.description,
    required this.dateDetection,
    this.dateResolution,
    required this.statut,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_reclamation': idReclamation,
      'id_technicien': idTechnicien,
      'description': description,
      'date_detection': dateDetection.toIso8601String(),
      'date_resolution': dateResolution?.toIso8601String(),
      'statut': statut,
    };
  }
  
  static Panne fromMap(Map<String, dynamic> map) {
    return Panne(
      id: map['id'],
      idReclamation: map['id_reclamation'],
      idTechnicien: map['id_technicien'],
      description: map['description'],
      dateDetection: DateTime.parse(map['date_detection']),
      dateResolution: map['date_resolution'] != null 
          ? DateTime.parse(map['date_resolution']) 
          : null,
      statut: map['statut'],
    );
  }
}

