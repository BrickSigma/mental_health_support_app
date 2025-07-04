import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/dass_model.dart';
import 'package:mental_health_support_app/models/patient_model.dart';

class SentimentAnalysisForm extends StatelessWidget {
  const SentimentAnalysisForm(this.patientModel, {super.key});

  final PatientModel patientModel;

  void onSubmit(BuildContext context, List<QuestionModel> questions) async {
    DASSModel result = await DASSModel.upldoadForm(
      patientModel.userInfo!.uid,
      DateTime.now(),
      questions.map((e) => e.score).toList(),
    );
    patientModel.setDASSModel(result);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<QuestionModel> questions = [
      for (String question in dassQuestions) QuestionModel(question),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("DASS-21 Form"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (QuestionModel questionModel in questions)
              QuestionCard(questionModel),
            FilledButton(
              onPressed: () => onSubmit(context, questions),
              child: Text("Submit"),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  const QuestionCard(this.questionModel, {super.key});

  final QuestionModel questionModel;

  @override
  Widget build(BuildContext context) {
    final List<String> scoreTexts = [
      "Never",
      "Sometimes",
      "Often",
      "Almost Always",
    ];

    return Padding(
      padding: EdgeInsets.all(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: ListenableBuilder(
            listenable: questionModel,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    questionModel.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < 4; i++)
                        Column(
                          children: [
                            Text(scoreTexts[i]),
                            Radio<int>(
                              value: i,
                              groupValue: questionModel.score,
                              onChanged:
                                  (value) => questionModel.setScore(value ?? 0),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
