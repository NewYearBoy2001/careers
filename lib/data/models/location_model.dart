class StateModel {
  final int id;
  final String name;

  const StateModel({required this.id, required this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) =>
      StateModel(id: json['id'], name: json['name']);
}

class DistrictModel {
  final int id;
  final int stateId;
  final String name;

  const DistrictModel({required this.id, required this.stateId, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
    id: json['id'],
    stateId: int.parse(json['state_id'].toString()),
    name: json['name'],
  );
}