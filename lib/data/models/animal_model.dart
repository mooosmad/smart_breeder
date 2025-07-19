class AnimalModel {
  final int? id;
  final String type; // Bovins, Ovins, Volailles, etc.
  final String subType; // Poulets de chair, Pondeuses, etc.
  final int count;
  final int ageInMonths;
  final String category; // Jeunes, Adultes, Reproducteurs
  final String? breed; // Holstein, Cobb 500, etc.
  final String physiologicalStage; // Gestation, Lactation, etc.
  final double? averageWeight;
  final String productionObjective;
  final String healthStatus;
  final String location;
  final double? temperature;
  final String housingType;
  final String soilType;
  final List<String> availableResources;
  final int workforce;
  final String feedingType;
  final int feedingFrequency;
  final String? performanceHistory;
  final String timeAvailability;
  final List<String> specificConstraints;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Champs spécifiques aux poulets
  final String? arrivalStatus;
  final String? origin;
  final double? buildingArea;
  final String? budget;

  AnimalModel({
    this.id,
    required this.type,
    required this.subType,
    required this.count,
    required this.ageInMonths,
    required this.category,
    this.breed,
    required this.physiologicalStage,
    this.averageWeight,
    required this.productionObjective,
    required this.healthStatus,
    required this.location,
    this.temperature,
    required this.housingType,
    required this.soilType,
    required this.availableResources,
    required this.workforce,
    required this.feedingType,
    required this.feedingFrequency,
    this.performanceHistory,
    required this.timeAvailability,
    required this.specificConstraints,
    required this.createdAt,
    required this.updatedAt,
    this.arrivalStatus,
    this.origin,
    this.buildingArea,
    this.budget,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'subType': subType,
      'count': count,
      'ageInMonths': ageInMonths,
      'category': category,
      'breed': breed,
      'physiologicalStage': physiologicalStage,
      'averageWeight': averageWeight,
      'productionObjective': productionObjective,
      'healthStatus': healthStatus,
      'location': location,
      'temperature': temperature,
      'housingType': housingType,
      'soilType': soilType,
      'availableResources': availableResources.join(','),
      'workforce': workforce,
      'feedingType': feedingType,
      'feedingFrequency': feedingFrequency,
      'performanceHistory': performanceHistory,
      'timeAvailability': timeAvailability,
      'specificConstraints': specificConstraints.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'arrivalStatus': arrivalStatus,
      'origin': origin,
      'buildingArea': buildingArea,
      'budget': budget,
    };
  }

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'],
      type: json['type'],
      subType: json['subType'],
      count: json['count'],
      ageInMonths: json['ageInMonths'],
      category: json['category'],
      breed: json['breed'],
      physiologicalStage: json['physiologicalStage'],
      averageWeight: json['averageWeight']?.toDouble(),
      productionObjective: json['productionObjective'],
      healthStatus: json['healthStatus'],
      location: json['location'],
      temperature: json['temperature']?.toDouble(),
      housingType: json['housingType'],
      soilType: json['soilType'],
      availableResources: json['availableResources'].split(','),
      workforce: json['workforce'],
      feedingType: json['feedingType'],
      feedingFrequency: json['feedingFrequency'],
      performanceHistory: json['performanceHistory'],
      timeAvailability: json['timeAvailability'],
      specificConstraints: json['specificConstraints'].split(','),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      arrivalStatus: json['arrivalStatus'],
      origin: json['origin'],
      buildingArea: json['buildingArea']?.toDouble(),
      budget: json['budget'],
    );
  }

  AnimalModel copyWith({
    int? id,
    String? type,
    String? subType,
    int? count,
    int? ageInMonths,
    String? category,
    String? breed,
    String? physiologicalStage,
    double? averageWeight,
    String? productionObjective,
    String? healthStatus,
    String? location,
    double? temperature,
    String? housingType,
    String? soilType,
    List<String>? availableResources,
    int? workforce,
    String? feedingType,
    int? feedingFrequency,
    String? performanceHistory,
    String? timeAvailability,
    List<String>? specificConstraints,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? arrivalStatus,
    String? origin,
    double? buildingArea,
    String? budget,
  }) {
    return AnimalModel(
      id: id ?? this.id,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      count: count ?? this.count,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      category: category ?? this.category,
      breed: breed ?? this.breed,
      physiologicalStage: physiologicalStage ?? this.physiologicalStage,
      averageWeight: averageWeight ?? this.averageWeight,
      productionObjective: productionObjective ?? this.productionObjective,
      healthStatus: healthStatus ?? this.healthStatus,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      housingType: housingType ?? this.housingType,
      soilType: soilType ?? this.soilType,
      availableResources: availableResources ?? this.availableResources,
      workforce: workforce ?? this.workforce,
      feedingType: feedingType ?? this.feedingType,
      feedingFrequency: feedingFrequency ?? this.feedingFrequency,
      performanceHistory: performanceHistory ?? this.performanceHistory,
      timeAvailability: timeAvailability ?? this.timeAvailability,
      specificConstraints: specificConstraints ?? this.specificConstraints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      arrivalStatus: arrivalStatus ?? this.arrivalStatus,
      origin: origin ?? this.origin,
      buildingArea: buildingArea ?? this.buildingArea,
      budget: budget ?? this.budget,
    );
  }
}