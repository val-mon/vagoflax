import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'package:provider/provider.dart';
import 'views/home_screen.dart';
import 'providers/job_provider.dart';
import 'repositories/firestore_job_repository.dart';
import 'utils/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: '.env');

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
        ChangeNotifierProvider(create: (_) => JobProvider(FirestoreJobRepository())),
      ],
      child: MaterialApp(
        title: 'Vagoflax',
        theme: buildThemeData(),
        home: const HomeScreen(),
      ),
    );
  }
}