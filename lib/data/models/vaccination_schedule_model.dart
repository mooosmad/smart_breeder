class VaccinationScheduleModel {
  final int? id;
  final int animalId;
  final String vaccineName;
  final String vaccineType; // Vaccination, Vermifugation, Traitement
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status; // pending, completed, overdue
  final String? notes;
  final double? estimatedCost;
  final double? actualCost;
  final String priority; // high, medium, low
  final String? veterinaryAdvice;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaccinationScheduleModel({
    this.id,
    required this.animalId,
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    this.notes,
    this.estimatedCost,
    this.actualCost,
    required this.priority,
    this.veterinaryAdvice,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'vaccineName': vaccineName,
      'vaccineType': vaccineType,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'priority': priority,
      'veterinaryAdvice': veterinaryAdvice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VaccinationScheduleModel.fromJson(Map<String, dynamic> json) {
    return VaccinationScheduleModel(
      id: json['id'],
      animalId: json['animalId'],
      vaccineName: json['vaccineName'],
      vaccineType: json['vaccineType'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate']) 
          : null,
      status: json['status'],
      notes: json['notes'],
      estimatedCost: json['estimatedCost']?.toDouble(),
      actualCost: json['actualCost']?.toDouble(),
      priority: json['priority'],
      veterinaryAdvice: json['veterinaryAdvice'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  VaccinationScheduleModel copyWith({
    int? id,
    int? animalId,
    String? vaccineName,
    String? vaccineType,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? status,
    String? notes,
    double? estimatedCost,
    double? actualCost,
    String? priority,
    String? veterinaryAdvice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaccinationScheduleModel(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccineType: vaccineType ?? this.vaccineType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      priority: priority ?? this.priority,
      veterinaryAdvice: veterinaryAdvice ?? this.veterinaryAdvice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(scheduledDate) && status != 'completed';
  bool get isDueToday => scheduledDate.difference(DateTime.now()).inDays == 0;
  bool get isDueSoon => scheduledDate.difference(DateTime.now()).inDays <= 3 && 
  scheduledDate.difference(DateTime.now()).inDays > 0;
}