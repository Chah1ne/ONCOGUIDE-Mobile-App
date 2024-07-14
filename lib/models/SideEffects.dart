class SideEffect {
  final int id;
  final int userId;
  final String userEmail; // Add email field
  final String selectedSymptom;
  final String selectedType;
  final String selectedSeverity;
  final String duration; // Change the type to String
  final String additionalNotes;
  final String imageUrl;
  final String selectedSideEffects;
  final String createdAt;
  final String updatedAt;
  final int? doctorId; // Nullable doctorId
  final String? doctorResponse; // Nullable doctorResponse


  SideEffect({
    required this.id,
    required this.userId,
    required this.userEmail, // Update constructor
    required this.selectedSymptom,
    required this.selectedType,
    required this.selectedSeverity,
    required this.duration,
    required this.additionalNotes,
    required this.imageUrl,
    required this.selectedSideEffects,
    required this.createdAt,
    required this.updatedAt,
    required this.doctorId,
    this.doctorResponse,


  });

  factory SideEffect.fromJson(Map<String, dynamic> json) {
    return SideEffect(
      id: json['id'],
      userId: json['userId'],
      userEmail: json['User']['email'], // Get email from nested user object
      selectedSymptom: json['selectedSymptom'],
      selectedType: json['selectedType'],
      selectedSeverity: json['selectedSeverity'],
      duration: json['duration'].toString(), // Convert to String
      additionalNotes: json['additionalNotes'],
      imageUrl: json['imageUrl'],
      selectedSideEffects: json['selectedSideEffects'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      doctorId: json['doctorId'],
      doctorResponse: json['doctorResponse'], // Parse doctorResponse

    );
  }
}
