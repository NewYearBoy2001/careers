class CareerNode {
  final String id;
  final String title;
  final String? thumbnail;

  CareerNode({
    required this.id,
    required this.title,
    this.thumbnail,
  });

  factory CareerNode.fromJson(Map<String, dynamic> json) {
    return CareerNode(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
    };
  }
}

class CareerNodeDetails {
  final String id;
  final String title;
  final List<String> subjects;
  final List<String> careerOptions;
  final String description;
  final String video;
  final String thumbnail;

  CareerNodeDetails({
    required this.id,
    required this.title,
    required this.subjects,
    required this.careerOptions,
    required this.description,
    required this.video,
    required this.thumbnail,
  });

  factory CareerNodeDetails.fromJson(Map<String, dynamic> json) {
    return CareerNodeDetails(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subjects: _parseStringList(json['subjects']),
      careerOptions: _parseStringList(json['career_options']),
      description: json['description'] ?? '',
      video: json['video'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  /// ✅ IMPROVED: Robust list parsing that handles multiple formats
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    // Case 1: Already a List
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    // Case 2: JSON string that needs parsing
    if (value is String) {
      final trimmed = value.trim();

      // Empty string
      if (trimmed.isEmpty) return [];

      // JSON array format: ["item1", "item2"]
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          // Remove brackets and split by comma
          final content = trimmed.substring(1, trimmed.length - 1);
          if (content.trim().isEmpty) return [];

          return content
              .split(',')
              .map((item) => item.trim())
              .map((item) {
            // Remove surrounding quotes if present
            if ((item.startsWith('"') && item.endsWith('"')) ||
                (item.startsWith("'") && item.endsWith("'"))) {
              return item.substring(1, item.length - 1);
            }
            return item;
          })
              .where((item) => item.isNotEmpty)
              .toList();
        } catch (e) {
          // If parsing fails, return the whole string as a single item
          return [trimmed];
        }
      }

      // Single string value
      return [trimmed];
    }

    // Case 3: Unexpected type - return empty list
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subjects': subjects,
      'career_options': careerOptions,
      'description': description,
      'video': video,
      'thumbnail': thumbnail,
    };
  }

  // CareerNodeDetails copyWith({
  //   String? id,
  //   String? title,
  //   List<String>? subjects,
  //   List<String>? careerOptions,
  //   String? description,
  //   String? video,
  //   String? thumbnail,
  // }) {
  //   return CareerNodeDetails(
  //     id: id ?? this.id,
  //     title: title ?? this.title,
  //     subjects: subjects ?? this.subjects,
  //     careerOptions: careerOptions ?? this.careerOptions,
  //     description: description ?? this.description,
  //     video: video ?? this.video,
  //     thumbnail: thumbnail ?? this.thumbnail,
  //   );
  // }
}

class SearchCareersResponse {
  final List<CareerNode> careernodes;
  final int totalNodes;

  SearchCareersResponse({
    required this.careernodes,
    required this.totalNodes,
  });

  factory SearchCareersResponse.fromJson(Map<String, dynamic> json) {
    return SearchCareersResponse(
      careernodes: (json['careernodes'] as List?)
          ?.map((e) => CareerNode.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      totalNodes: int.tryParse(json['total_nodes']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'careernodes': careernodes.map((e) => e.toJson()).toList(),
      'total_nodes': totalNodes,
    };
  }
}