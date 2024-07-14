class Product {
  final int id;
  final int idCure;
  final int idMolecule;
  final String dose;
  final String name;
  final DateTime  startDate;
  final int validation;
  final int adjusted;
  final int liberer;
  final int terminer;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.idCure,
    required this.idMolecule,
    required this.dose,
    required this.name,
    required this.startDate,
    required this.validation,
    required this.adjusted,
    required this.liberer,
    required this.terminer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      idCure: json['id_cure'],
      idMolecule: json['id_molecule'],
      dose: json['dose'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      validation: json['validation'],
      adjusted: json['adjusted'],
      liberer: json['liberer'],
      terminer: json['terminer'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}