import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'views/home_screen.dart';
import 'providers/job_provider.dart';
import 'repositories/firestore_job_repository.dart';
import 'repositories/fake_job_repository.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider(FakeJobRepository())),
      ],
      child: MaterialApp(
        title: 'Vagoflax',
        theme: buildThemeData(),
        home: const HomeScreen(),
      ),
    );
  }
}