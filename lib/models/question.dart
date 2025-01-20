class Question {
  final int id;
  final String title;
  final String description;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      answers: (json['answers'] as List)
          .map((answerJson) => Answer.fromJson(answerJson))
          .toList(),
    );
  }
}

class Answer {
  final int id;
  final bool isCorrect;
  final String pictureTitle;
  final String pictureDescription;
  final String pictureAuthor;
  final String pictureCreateDate;
  final String pictureResizePath;
  final String pictureOriginalPath;

  Answer({
    required this.id,
    required this.isCorrect,
    required this.pictureTitle,
    required this.pictureDescription,
    required this.pictureAuthor,
    required this.pictureCreateDate,
    required this.pictureResizePath,
    required this.pictureOriginalPath,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      isCorrect: json['is_correct'],
      pictureTitle: json['picture_title'],
      pictureDescription: json['picture_description'],
      pictureAuthor: json['picture_author'],
      pictureCreateDate: json['picture_create_date'],
      pictureResizePath: json['picture_resize_path'],
      pictureOriginalPath: json['picture_original_path'],
    );
  }
}
