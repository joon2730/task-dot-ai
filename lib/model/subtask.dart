class Subtask {
  String title;
  bool isCompleted;

  Subtask(this.title, {this.isCompleted = false});

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isCompleted': isCompleted};
  }
}
