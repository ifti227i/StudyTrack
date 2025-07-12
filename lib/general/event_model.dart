class EventModel {
  final int? id;
  final DateTime date;
  final String type;
  final String details;
  final String editedBy;
  final DateTime? createdAt;

  EventModel({
    this.id,
    required this.date,
    required this.type,
    required this.details,
    required this.editedBy,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      details: json['details'],
      editedBy: json['editedBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      'details': details,
      'editedBy': editedBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
