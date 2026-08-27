import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vagoflax/providers/user_provider.dart';
import 'package:vagoflax/repositories/firestore_user_repository.dart';
import 'package:vagoflax/utils/router.dart';

import 'utils/theme.dart';

import 'package:provider/provider.dart';

import 'providers/job_provider.dart';
import 'repositories/firestore_job_repository.dart';
import 'utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplicationState()),
        ChangeNotifierProvider(
          create: (_) => JobProvider(FirestoreJobRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(FirestoreUserRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Vagoflax',
        theme: buildThemeData(),
        routerConfig: router,
      ),
    );
  }
}
