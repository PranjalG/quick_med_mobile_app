import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_med/services/router.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:path_provider/path_provider.dart';

// late HydratedStorage hydratedStorage;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/blocs/cart_cubit/cart_cubit.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/services/supabase_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Cart persistence. Application-documents rather than temp: the OS may clear
  // temp at any time, and a cart vanishing mid-session is worse than no cart.
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  // Supabase data client — Firebase ID token wired for Third-Party Auth / RLS.
  await SupabaseConfig.initialize();
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
    // Cart lives above the router so it survives navigation between tabs
    // and routes, and is restored from disk on launch.
    return BlocProvider(
      create: (_) => CartCubit(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'Quick Med mobile app',
        theme: AppTheme.light,
      ),
    );
  }
}
