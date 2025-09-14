import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutteruis/providers/chat_provider.dart';
import 'package:flutteruis/screens/extra_designs/cyber_orb.dart';
import 'package:flutteruis/screens/extra_designs/orb2.dart' hide InterstellarLoginScreen;
import 'package:flutteruis/screens/extra_designs/orb3.dart' hide InterstellarLoginScreen;
import 'package:flutteruis/screens/medical_app/splash_screen.dart';
import 'package:flutteruis/screens/signup/SupernovaSignupScreen.dart';
import 'package:flutteruis/screens/signup/biometric_signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/login_provider.dart';
import 'package:flutteruis/providers/signup_provider.dart';
import 'package:flutteruis/screens/login/biometric_login_screen.dart';
import 'package:flutteruis/screens/login/infernal_logix_login.dart';
import 'package:flutteruis/screens/login/quantum_gate_login_screen.dart';
import 'package:flutteruis/screens/login/super_nova_login_2.dart';
import 'package:flutteruis/screens/login/super_nova_login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),

        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.cyan,
        ),
        home: medSplashScreen(),
      ),
    );
  }
}