import 'package:mental_health_support_app/firebase_options.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/views/app/app.dart';
import 'package:mental_health_support_app/views/login/login.dart';
import 'package:mental_health_support_app/views/login/verify_account.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  await setupApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

Future<void> setupApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<LoginProvider>(context, listen: false).getAuthState();

    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<LoginProvider>(
        builder: (context, auth, child) {
          return !auth.loggedIn
              ? LoginView()
              : auth.isVerified != true
              ? VerifyAccountView()
              : App();
        },
      ),
    );
  }
}