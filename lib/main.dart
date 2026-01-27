import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'router/app_router.dart';
import 'data/api/auth_api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'utils/prefs/auth_local_storage.dart';
import 'data/repositories/admission_banner_repository.dart';
import 'data/api/admission_banner_api.dart';
import 'data/api/college_api_service.dart';
import 'data/repositories/college_repository.dart';
import 'bloc/admission_banner/admission_banner_bloc.dart';
import 'bloc/college/college_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // ========================================
        // CORE SERVICES (Foundation Layer)
        // ========================================
        RepositoryProvider<AuthLocalStorage>(
          create: (_) => AuthLocalStorage(),
        ),

        // ========================================
        // API SERVICES (Network Layer)
        // ========================================
        RepositoryProvider<AuthApiService>(
          create: (_) => AuthApiService(),
        ),

        RepositoryProvider<AdmissionApiService>(
          create: (_) => AdmissionApiService(),
        ),

        RepositoryProvider<CollegeApiService>(
          create: (context) => CollegeApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        // ========================================
        // REPOSITORIES (Business Logic Layer)
        // ========================================
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            context.read<AuthApiService>(),
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<AdmissionRepository>(
          create: (context) => AdmissionRepository(
            context.read<AdmissionApiService>(),
          ),
        ),

        RepositoryProvider<CollegeRepository>(
          create: (context) => CollegeRepository(
            context.read<CollegeApiService>(),
          ),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          // ========================================
          // GLOBAL BLOCS (Available Everywhere)
          // ========================================

          BlocProvider<AdmissionBloc>(
            create: (context) => AdmissionBloc(
              context.read<AdmissionRepository>(),
            ),
          ),

          BlocProvider<CollegeBloc>(
            create: (context) => CollegeBloc(
              context.read<CollegeRepository>(),
            ),
          ),

          // Add more global blocs here as needed
        ],

        child: MaterialApp.router(
          title: 'Careers',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: ThemeData(useMaterial3: true),

          // Global keyboard dismiss
          builder: (context, child) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  currentFocus.unfocus();
                }
              },
              child: child!,
            );
          },
        ),
      ),
    );
  }
}