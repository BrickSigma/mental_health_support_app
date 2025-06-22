/// Used only for viewing the sentiment analysis form data
library;

import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/dass_model.dart';

class SentimentAnalysisFormView extends StatelessWidget {
  const SentimentAnalysisFormView(this.form, {super.key});

  final DASSModel form;

  @override
  Widget build(BuildContext context) {
    final List<QuestionModel> questions = [
      for (int i = 0; i < form.questionScores.length; i++)
        QuestionModel(dassQuestions[i], score: form.questionScores[i]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("DASS-21 Form"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (QuestionModel questionModel in questions)
              QuestionViewCard(questionModel),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class QuestionViewCard extends StatelessWidget {
  const QuestionViewCard(this.questionModel, {super.key});

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
          child: Column(
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
                          onChanged: null,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
