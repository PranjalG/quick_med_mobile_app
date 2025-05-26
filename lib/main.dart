import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_med/services/router.dart';
// import 'package:flutter_article_app/bloc/landing_bloc/landing_bloc.dart';
// import 'package:flutter_article_app/data/data_provider/landing_screen_data_provider.dart';
// import 'package:flutter_article_app/data/repository/landing_screen_repository.dart';
// import 'package:flutter_article_app/services/router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:path_provider/path_provider.dart';

// late HydratedStorage hydratedStorage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final directory = await getApplicationDocumentsDirectory();
  // final hydratedStorageDirectory = HydratedStorageDirectory(directory.path);
  // hydratedStorage = await HydratedStorage.build(
  //   storageDirectory: hydratedStorageDirectory,
  // );
  // HydratedBloc.storage = hydratedStorage;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final repository = LandingScreenRepository(LandingScreenDataProvider());
    return  MaterialApp.router(
        routerConfig: router,
        title: 'Flutter Articles App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
        ),
    );
  }
}
