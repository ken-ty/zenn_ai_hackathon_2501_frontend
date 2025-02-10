class NewQuestion {
  final int id;
  final String title;
  final String description;

  NewQuestion({
    required this.id,
    required this.title,
    required this.description,
  });

  factory NewQuestion.fromJson(Map<String, dynamic> json) {
    return NewQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
