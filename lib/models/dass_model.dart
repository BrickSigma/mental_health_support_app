import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<String> dassQuestions = [
  "I found it hard to wind down",
  "I was aware of dryness of my mouth",
  "I couldn't seem to experience any positive feeling at all",
  "I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion)",
  "I found it difficult to work up the initiative to do things",
  "I tended to over-react to situations",
  "I experienced trembling (e.g. in the hands)",
  "I felt that I was using a lot of nervous energy",
  "I was worried about situations in which I might panic and make a fool of myself",
  "I felt that I had nothing to look forward to",
  "I found myself getting agitated",
  "I found it difficult to relax",
  "I felt down-hearted and blue",
  "I was intolerant of anything that kept me from getting on with what I was doing",
  "I felt I was close to panic",
  "I was unable to become enthusiastic about anything",
  "I felt I wasn't worth much as a person",
  "I felt that I was rather touchy",
  "I was aware of the action of my heart in the absence of physical exertion (e.g. sense of heart rate increase, heart missing a beat)",
  "I felt scared without any good reason",
  "I felt that life was meaningless",
];

/// Model for a single DASS Form.
class DASSModel extends ChangeNotifier {
  String id = "";
  DateTime timeFilledIn = DateTime.now();
  int totalScore = 0;
  int depressionScore = 0;
  int anxietyScore = 0;
  int stressScore = 0;
  List<int> questionScores = List.filled(21, 0, growable: false);

  String getDepressionStatus() {
    if (depressionScore <= 9) {
      return "Normal";
    } else if (depressionScore <= 13) {
      return "Mild";
    } else if (depressionScore <= 20) {
      return "Moderate";
    } else if (depressionScore <= 27) {
      return "Severe";
    } else {
      return "Extremely Severe";
    }
  }

  String getAnxietyStatus() {
    if (anxietyScore <= 7) {
      return "Normal";
    } else if (anxietyScore <= 9) {
      return "Mild";
    } else if (anxietyScore <= 14) {
      return "Moderate";
    } else if (anxietyScore <= 19) {
      return "Severe";
    } else {
      return "Extremely Severe";
    }
  }

  String getStressStatus() {
    if (depressionScore <= 14) {
      return "Normal";
    } else if (depressionScore <= 18) {
      return "Mild";
    } else if (depressionScore <= 25) {
      return "Moderate";
    } else if (depressionScore <= 33) {
      return "Severe";
    } else {
      return "Extremely Severe";
    }
  }

  DASSModel(this.id, this.timeFilledIn, this.questionScores) {
    assert(questionScores.length == 21);

    totalScore = questionScores.reduce((value, element) => value + element);

    List<int> depressionQuestions = [3, 5, 10, 13, 16, 17, 21];
    List<int> anxietyQuestions = [2, 4, 7, 9, 15, 19, 20];
    List<int> stressQuestions = [1, 6, 8, 11, 12, 14, 18];

    for (int index in depressionQuestions) {
      depressionScore += questionScores[index - 1];
    }
    depressionScore *= 2;

    for (int index in anxietyQuestions) {
      anxietyScore += questionScores[index - 1];
    }
    anxietyScore *= 2;

    for (int index in stressQuestions) {
      stressScore += questionScores[index - 1];
    }
    stressScore *= 2;
  }

  static DASSModel loadFromDocument(QueryDocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    List<int> questions = List<int>.from(data["questionScores"]);
    DateTime timeFilledIn = (data["timeFilledIn"] as Timestamp).toDate();

    return DASSModel(document.id, timeFilledIn, questions);
  }

  /// Upload a new form entry to firebase.
  static Future<DASSModel> upldoadForm(
    String patientId,
    DateTime timeFilledIn,
    List<int> questionScores,
  ) async {
    final db = FirebaseFirestore.instance;

    final document = await db
        .collection("patients")
        .doc(patientId)
        .collection("sentimentForms")
        .add({
          "timeFilledIn": Timestamp.fromDate(timeFilledIn),
          "questionScores": questionScores,
        });

    return DASSModel(document.id, timeFilledIn, questionScores);
  }
}

class QuestionModel extends ChangeNotifier {
  final String title;
  int score;

  QuestionModel(this.title, {this.score = 0});

  void setScore(int score) {
    this.score = score;
    notifyListeners();
  }
}
