import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Model for a single DASS Form.
class DASSModel extends ChangeNotifier {
  String id = "";
  DateTime timeFilledIn = DateTime.now();
  int totalScore = 0;
  int depressionScore = 0;
  int anxietyScore = 0;
  int stressScore = 0;
  List<int> questionScores = List.filled(21, 0, growable: false);

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
