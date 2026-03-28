class Task {
  final int? id;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  // 👇 Naya field: Parent task ka ID save karne ke liye
  final int? blockedBy; 

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      // Backend snake_case bhejta hai, Flutter camelCase use karta hai
      dueDate: json['due_date'] ?? json['dueDate'] ?? '',
      status: json['status'] ?? 'To-Do',
      blockedBy: json['blocked_by'] ?? json['blockedBy'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate,
      'status': status,
      'blocked_by': blockedBy,
    };
  }
}