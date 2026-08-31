import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vagoflax/providers/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vagoflax/providers/application.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/repositories/firestore_application.dart';
import 'package:vagoflax/repositories/firestore_user.dart';
import 'package:vagoflax/utils/router.dart';

import 'package:vagoflax/utils/firebase_options.dart';
import 'package:vagoflax/repositories/firestore_job.dart';
import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/utils/theme.dart';

import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => UserProvider(FirestoreUserRepository()),
        ),
        ChangeNotifierProxyProvider<UserProvider, ApplicationState>(
          create: (context) =>
              ApplicationState(userProvider: context.read<UserProvider>()),
          update: (_, userProvider, previousState) =>
              (previousState ?? ApplicationState(userProvider: userProvider))
                ..updateUserProvider(userProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => JobProvider(FirestoreJobRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationProvider(FirestoreApplicationRepository()),
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
