class EnergyRecommendationModel {
  final String id;
  final String meterId;
  final String title;
  final String subtitle;
  final String badgeText; // e.g. 'Suggested', 'YOUR NEXT BEST STEP'
  final String reason;
  final String action;
  final String expectedBenefit;
  final bool isHeroStep;
  final bool isSaved;
  final String category;
  final int priority;

  EnergyRecommendationModel({
    required this.id,
    required this.meterId,
    required this.title,
    this.subtitle = '',
    this.badgeText = 'Suggested',
    this.reason = '',
    this.action = '',
    this.expectedBenefit = '',
    this.isHeroStep = false,
    this.isSaved = false,
    this.category = 'Efficiency',
    this.priority = 1,
  });

  EnergyRecommendationModel copyWith({
    String? id,
    String? meterId,
    String? title,
    String? subtitle,
    String? badgeText,
    String? reason,
    String? action,
    String? expectedBenefit,
    bool? isHeroStep,
    bool? isSaved,
    String? category,
    int? priority,
  }) {
    return EnergyRecommendationModel(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      badgeText: badgeText ?? this.badgeText,
      reason: reason ?? this.reason,
      action: action ?? this.action,
      expectedBenefit: expectedBenefit ?? this.expectedBenefit,
      isHeroStep: isHeroStep ?? this.isHeroStep,
      isSaved: isSaved ?? this.isSaved,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meterId': meterId,
      'title': title,
      'subtitle': subtitle,
      'badgeText': badgeText,
      'reason': reason,
      'action': action,
      'expectedBenefit': expectedBenefit,
      'isHeroStep': isHeroStep,
      'isSaved': isSaved,
      'category': category,
      'priority': priority,
    };
  }

  factory EnergyRecommendationModel.fromMap(Map<String, dynamic> map, String docId) {
    return EnergyRecommendationModel(
      id: docId,
      meterId: map['meterId'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      badgeText: map['badgeText'] ?? 'Suggested',
      reason: map['reason'] ?? '',
      action: map['action'] ?? '',
      expectedBenefit: map['expectedBenefit'] ?? '',
      isHeroStep: map['isHeroStep'] ?? false,
      isSaved: map['isSaved'] ?? false,
      category: map['category'] ?? 'Efficiency',
      priority: (map['priority'] as num?)?.toInt() ?? 1,
    );
  }
}
