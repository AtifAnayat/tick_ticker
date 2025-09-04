class TaskModel {
  String id;
  String title;
  String content;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  bool isNote;
  String category;

  TaskModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
    required this.createdAt,
    this.dueDate,
    required this.isNote,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isNote': isNote,
      'category': category,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isNote: json['isNote'],
      category: json['category'],
    );
  }
}