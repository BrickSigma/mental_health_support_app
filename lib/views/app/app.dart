import 'package:mental_health_support_app/controllers/soundtrack_controller.dart';
import 'package:mental_health_support_app/models/journal_model.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/user_interface.dart';
import 'package:mental_health_support_app/views/app/patient/patient_app.dart';
import 'package:mental_health_support_app/views/app/therapist/therapist_app.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Future<
    ({
      UserRole userRole,
      TherapistModel? therapistModel,
      PatientModel? patientModel,
      SoundtrackController? soundtrackController,
      JournalModel? journalModel,
    })
  >?
  _data;

  /// Used to load the user data from firebase.
  Future<
    ({
      UserRole userRole,
      TherapistModel? therapistModel,
      PatientModel? patientModel,
      SoundtrackController? soundtrackController,
      JournalModel? journalModel,
    })
  >
  _getUserData() async {
    UserRole userRole = await checkUserRole(
      FirebaseAuth.instance.currentUser!.uid,
    );

    TherapistModel? therapistModel;
    PatientModel? patientModel;
    SoundtrackController? soundtrackController;
    JournalModel? journalModel;

    if (userRole == UserRole.therapist) {
      therapistModel = TherapistModel();
      await therapistModel.loadUserData(FirebaseAuth.instance.currentUser!);
    } else {
      patientModel = PatientModel();
      await patientModel.loadUserData(FirebaseAuth.instance.currentUser!);
      soundtrackController = SoundtrackController();
      await soundtrackController.loadPlayers();
      journalModel = JournalModel();
      await journalModel.loadJournal(patientModel.userInfo!.uid);
    }

    return (
      userRole: userRole,
      therapistModel: therapistModel,
      patientModel: patientModel,
      soundtrackController: soundtrackController,
      journalModel: journalModel,
    );
  }

  @override
  void initState() {
    _data = _getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        Widget child;

        LoginProvider loginProvider = Provider.of(context, listen: false);

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData &&
              snapshot.data!.userRole != UserRole.nonExistent) {
            if (snapshot.data!.userRole == UserRole.patient) {
              child = MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: snapshot.data!.patientModel!,
                  ),
                  ChangeNotifierProvider.value(
                    value: snapshot.data!.soundtrackController!,
                  ),
                  ChangeNotifierProvider.value(
                    value: snapshot.data!.journalModel!,
                  ),
                ],
                child: PatientApp(),
              );
            } else {
              child = ChangeNotifierProvider<TherapistModel>.value(
                value: snapshot.data!.therapistModel!,
                child: TherapistApp(),
              );
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
                      onPressed: () => loginProvider.logout(),
                      child: Text("Go back to login"),
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
