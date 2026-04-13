class CareerNode {
  final String id;
  final String title;
  final String? thumbnail;
  final bool isNewgenCourse;

  CareerNode({
    required this.id,
    required this.title,
    this.thumbnail,
    this.isNewgenCourse = false,
  });

  factory CareerNode.fromJson(Map<String, dynamic> json) {
    return CareerNode(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      isNewgenCourse: json['is_newgen_course'] == 1 ||   // ADD THIS
          json['is_newgen_course'] == '1' ||
          json['is_newgen_course'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'is_newgen_course': isNewgenCourse ? 1 : 0,
    };
  }
}

class CareerNodeDetails {
  final String id;
  final String title;
  final List<String> subjects;
  final List<String> careerOptions;
  final String description;
  final String videoId;
  final String videoUrl;
  final String? thumbnail;
  final bool isNewgenCourse;
  final bool hasFuturePath;


  CareerNodeDetails({
    required this.id,
    required this.title,
    required this.subjects,
    required this.careerOptions,
    required this.description,
    required this.videoId,
    required this.videoUrl,
    this.thumbnail,
    required this.isNewgenCourse,
    required this.hasFuturePath,
  });

  factory CareerNodeDetails.fromJson(Map<String, dynamic> json) {
    return CareerNodeDetails(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subjects: _parseStringList(json['subjects']),
      careerOptions: _parseStringList(json['career_options']),
      description: json['description'] ?? '',
      // Treat null or empty string the same way
      videoId: (json['video_id']?.toString() ?? '').trim(),
      videoUrl: (json['video_url']?.toString() ?? '').trim(),
      // null stays null; empty string becomes null
      thumbnail: (json['thumbnail']?.toString() ?? '').trim().isEmpty
          ? null
          : json['thumbnail'].toString().trim(),
      isNewgenCourse: json['is_newgen_course'] == 1 ||
          json['is_newgen_course'] == '1' ||
          json['is_newgen_course'] == true,
      hasFuturePath: json['has_future_path'] == 1 ||
          json['has_future_path'] == '1' ||
          json['has_future_path'] == true,
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
      'video_id': videoId,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'is_newgen_course': isNewgenCourse ? 1 : 0,
      'has_future_path': hasFuturePath ? 1 : 0,
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
  final int currentPage;
  final int lastPage;
  final int perPage;

  SearchCareersResponse({
    required this.careernodes,
    required this.totalNodes,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  factory SearchCareersResponse.fromJson(Map<String, dynamic> json) {
    return SearchCareersResponse(
      careernodes: (json['careernodes'] as List?)
          ?.map((e) => CareerNode.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalNodes: int.tryParse(json['total_nodes']?.toString() ?? '0') ?? 0,
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '5') ?? 5,
    );
  }
}

class CareerChildNodesResponse {
  final List<CareerNode> childNodes;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int totalChildren;

  CareerChildNodesResponse({
    required this.childNodes,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.totalChildren,
  });

  factory CareerChildNodesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CareerChildNodesResponse(
      childNodes: (data['child_nodes'] as List<dynamic>? ?? [])
          .map((e) => CareerNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: int.tryParse(data['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(data['last_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(data['per_page']?.toString() ?? '5') ?? 5,
      totalChildren: int.tryParse(data['total_children']?.toString() ?? '0') ?? 0,
    );
  }
}