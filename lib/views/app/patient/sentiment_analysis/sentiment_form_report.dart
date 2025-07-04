import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/dass_model.dart';
import 'package:mental_health_support_app/views/app/patient/sentiment_analysis/sentiment_analysis_form_view.dart';

class SentimentFormReportPage extends StatefulWidget {
  const SentimentFormReportPage(this.patientId, {super.key});

  final String patientId;

  @override
  State<SentimentFormReportPage> createState() =>
      _SentimentFormReportPageState();
}

class _SentimentFormReportPageState extends State<SentimentFormReportPage> {
  Future<List<DASSModel>> _getPatientForms() async {
    List<DASSModel> forms = [];

    final db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
        await db
            .collection("patients")
            .doc(widget.patientId)
            .collection("sentimentForms")
            .orderBy("timeFilledIn", descending: true)
            .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      DASSModel model = DASSModel.loadFromDocument(documentSnapshot);
      forms.add(model);
    }

    return forms;
  }

  Future<List<DASSModel>>? _data;

  @override
  void initState() {
    super.initState();
    _data = _getPatientForms();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              child = Scaffold(
                appBar: AppBar(
                  title: Text("Sentiment Analysis Report"),
                  centerTitle: true,
                ),
                body: Center(child: Text("Patient has no form data to show!")),
              );
            } else {
              child = SentimentFormReport(snapshot.data!);
            }
          } else {
            child = Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 160),
                    SizedBox(height: 12),
                    Text("Could not load data!"),
                    SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Go back"),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          child = Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}

class SentimentFormReport extends StatelessWidget {
  const SentimentFormReport(this.forms, {super.key});

  final List<DASSModel> forms;

  @override
  Widget build(BuildContext context) {
    // Store the scores for the last 10 form entries.
    List<int> depressionScores = [];
    List<int> anxietyScores = [];
    List<int> stressScores = [];

    int length = forms.length < 10 ? forms.length : 10;

    for (int i = 0; i < length; i++) {
      depressionScores.add(forms[i].depressionScore);
      anxietyScores.add(forms[i].anxietyScore);
      stressScores.add(forms[i].stressScore);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Sentiment Analysis Report"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                "* Data shown for last 10 form entries",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 12),
              Text(
                "Depression Scores",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 12),
              Chart(depressionScores, [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ]),
              SizedBox(height: 12),
              Text(
                "Anxiety Scores",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 12),
              Chart(anxietyScores, [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ]),
              SizedBox(height: 12),
              Text(
                "Stress Scores",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 12),
              Chart(stressScores, [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ]),
              SizedBox(height: 12),
              Text(
                "Previous Form Entries",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 12),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder:
                    (context, index) => ListTile(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      SentimentAnalysisFormView(forms[index]),
                            ),
                          ),
                      title: Text(forms[index].timeFilledIn.toString()),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                separatorBuilder:
                    (context, index) => Divider(thickness: 3, height: 0),
                itemCount: forms.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Chart extends StatelessWidget {
  const Chart(this.scores, this.gradientColors, {super.key});

  final List<int> scores;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget:
                      (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          value.toInt().toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            minX: 0,
            maxX: scores.length.toDouble() - 1,
            minY: 0,
            maxY: 21,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int index = 0; index < scores.length; index++)
                    FlSpot(index.toDouble(), scores[index]/2),
                ],
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    ColorTween(
                      begin: gradientColors[0],
                      end: gradientColors[1],
                    ).lerp(0)!,
                    ColorTween(
                      begin: gradientColors[0],
                      end: gradientColors[1],
                    ).lerp(1)!,
                  ],
                ),
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      ColorTween(
                        begin: gradientColors[0],
                        end: gradientColors[1],
                      ).lerp(0)!.withValues(alpha: 0.7),
                      ColorTween(
                        begin: gradientColors[0],
                        end: gradientColors[1],
                      ).lerp(1)!.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
