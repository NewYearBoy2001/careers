class FeeBreakdown {
  final String label;
  final String amount;

  FeeBreakdown({required this.label, required this.amount});

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) {
    return FeeBreakdown(
      label: json['label'] ?? '',
      amount: json['amount'] ?? '0',
    );
  }
}

class FeeStructure {
  final String feeStructureId;
  final String feeType;
  final String feeMode;
  final String totalAmount;
  final List<FeeBreakdown> breakdowns;

  FeeStructure({
    required this.feeStructureId,
    required this.feeType,
    required this.feeMode,
    required this.totalAmount,
    required this.breakdowns,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      feeStructureId: json['fee_structure_id'] ?? '',
      feeType: json['fee_type'] ?? '',
      feeMode: json['fee_mode'] ?? '',
      totalAmount: json['total_amount'] ?? '0',
      breakdowns: (json['breakdowns'] as List<dynamic>? ?? [])
          .map((e) => FeeBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class CourseFeeModel {
  final String courseId;
  final String courseName;
  final List<FeeStructure> feeStructures;

  CourseFeeModel({
    required this.courseId,
    required this.courseName,
    required this.feeStructures,
  });

  factory CourseFeeModel.fromJson(Map<String, dynamic> json) {
    return CourseFeeModel(
      courseId: json['course_id'] ?? '',
      courseName: json['course_name'] ?? '',
      feeStructures: (json['fee_structures'] as List<dynamic>? ?? [])
          .map((e) => FeeStructure.fromJson(e))
          .toList(),
    );
  }
}