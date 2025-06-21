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
      QuestionModel("I found it hard to wind down"),
      QuestionModel("I was aware of dryness of my mouth"),
      QuestionModel(
        "I couldn't seem to experience any positive feeling at all",
      ),
      QuestionModel(
        "I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion)",
      ),
      QuestionModel(
        "I found it difficult to work up the initiative to do things",
      ),
      QuestionModel("I tended to over-react to situations"),
      QuestionModel("I experienced trembling (e.g. in the hands)"),
      QuestionModel("I felt that I was using a lot of nervous energy"),
      QuestionModel(
        "I was worried about situations in which I might panic and make a fool of myself",
      ),
      QuestionModel("I felt that I had nothing to look forward to"),
      QuestionModel("I found myself getting agitated"),
      QuestionModel("I found it difficult to relax"),
      QuestionModel("I felt down-hearted and blue"),
      QuestionModel(
        "I was intolerant of anything that kept me from getting on with what I was doing",
      ),
      QuestionModel("I felt I was close to panic"),
      QuestionModel("I was unable to become enthusiastic about anything"),
      QuestionModel("I felt I wasn't worth much as a person"),
      QuestionModel("I felt that I was rather touchy"),
      QuestionModel(
        "I was aware of the action of my heart in the absence of physical exertion (e.g. sense of heart rate increase, heart missing a beat)",
      ),
      QuestionModel("I felt scared without any good reason"),
      QuestionModel("I felt that life was meaningless"),
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

class QuestionModel extends ChangeNotifier {
  final String title;
  int score = 0;

  QuestionModel(this.title);

  void setScore(int score) {
    this.score = score;
    notifyListeners();
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
