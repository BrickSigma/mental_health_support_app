import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/notifications.dart';
import 'package:mental_health_support_app/views/app/patient/sentiment_analysis/sentiment_analysis_form.dart';
import 'package:mental_health_support_app/views/app/patient/sentiment_analysis/sentiment_form_report.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String _dailyMessage(String? username) {
    final hour = DateTime.now().hour;
    return hour < 12
        ? "Good morning, ${username ?? ""}"
        : hour < 18
        ? "Good afternoon, ${username ?? ""}"
        : "Good evening, ${username ?? ""}";
  }

  @override
  Widget build(BuildContext context) {
    PatientModel patientModel = Provider.of(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_dailyMessage(patientModel.userName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientsNotification(),
                  ),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SentimentAnalysisSection()],
          ),
        ),
      ),
    );
  }
}

class SentimentAnalysisSection extends StatelessWidget {
  const SentimentAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    PatientModel patientModel = Provider.of(context, listen: false);

    return ListenableBuilder(
      listenable: patientModel.dassModel,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sentiment Analysis",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 12),
            if (patientModel.dassModel.value == null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "You haven't filled in a form yet.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (patientModel.dassModel.value != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total score: ${patientModel.dassModel.value!.totalScore}",
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Depression score: ${patientModel.dassModel.value!.getDepressionStatus()} (${patientModel.dassModel.value!.depressionScore})",
                      ),
                      SizedBox(height: 6),

                      Text(
                        "Anxiety score: ${patientModel.dassModel.value!.getAnxietyStatus()} (${patientModel.dassModel.value!.anxietyScore})",
                      ),
                      SizedBox(height: 6),

                      Text(
                        "Stress score: ${patientModel.dassModel.value!.getStressStatus()} (${patientModel.dassModel.value!.stressScore})",
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SentimentAnalysisForm(patientModel),
                        ),
                      ),
                  child: Text("Fill in a new form"),
                ),
                if (patientModel.dassModel.value != null)
                  FilledButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SentimentFormReportPage(
                                  patientModel.userInfo!.uid,
                                ),
                          ),
                        ),
                    child: Text("View form history"),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
