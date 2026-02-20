import 'package:flutter/material.dart';
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
import 'data/api/saved_college_api_service.dart';
import 'data/repositories/saved_college_repository.dart';
import 'bloc/saved_college/saved_college_bloc.dart';
import 'data/api/profile_api_service.dart';
import 'data/repositories/profile_repository.dart';
import 'bloc/profile/profile_bloc.dart';
import 'data/api/saved_colleges_list_api_service.dart';
import 'data/repositories/saved_colleges_list_repository.dart';
import 'bloc/saved_colleges_list/saved_colleges_list_bloc.dart';
import 'data/api/change_password_api_service.dart';
import 'data/repositories/change_password_repository.dart';
import 'bloc/change_password/change_password_bloc.dart';
import 'data/api/career_banner_api_service.dart';
import 'data/repositories/career_banner_repository.dart';
import 'bloc/career_banner/career_banner_bloc.dart';
import 'data/api/career_search_api_service.dart';
import 'data/repositories/career_search_repository.dart';
import 'bloc/career_search/career_search_bloc.dart';
import 'data/api/career_home_api_service.dart';
import 'data/repositories/career_home_repository.dart';
import 'bloc/career_home/career_home_bloc.dart';
import 'data/api/career_child_nodes_api_service.dart';
import 'data/repositories/career_child_nodes_repository.dart';
import 'bloc/career_child_nodes/career_child_nodes_bloc.dart';

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

        RepositoryProvider<SavedCollegeApiService>(
          create: (context) => SavedCollegeApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<ProfileApiService>(
          create: (context) => ProfileApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<SavedCollegesListApiService>(
          create: (context) => SavedCollegesListApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<ChangePasswordApiService>(
          create: (context) => ChangePasswordApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<CareerBannerApiService>(
          create: (context) => CareerBannerApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<CareerSearchApiService>(
          create: (context) => CareerSearchApiService(
            context.read<AuthLocalStorage>(),
          ),
        ),

        RepositoryProvider<CareerHomeApiService>(
          create: (context) => CareerHomeApiService(), // No parameter
        ),

        RepositoryProvider<CareerChildNodesApiService>(
          create: (context) => CareerChildNodesApiService(
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

        RepositoryProvider<SavedCollegeRepository>(
          create: (context) => SavedCollegeRepository(
            context.read<SavedCollegeApiService>(),
          ),
        ),

        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(
            context.read<ProfileApiService>(),
          ),
        ),

        RepositoryProvider<SavedCollegesListRepository>(
          create: (context) => SavedCollegesListRepository(
            context.read<SavedCollegesListApiService>(),
          ),
        ),

        RepositoryProvider<ChangePasswordRepository>(
          create: (context) => ChangePasswordRepository(
            context.read<ChangePasswordApiService>(),
          ),
        ),

        RepositoryProvider<CareerBannerRepository>(
          create: (context) => CareerBannerRepository(
            context.read<CareerBannerApiService>(),
          ),
        ),

        RepositoryProvider<CareerSearchRepository>(
          create: (context) => CareerSearchRepository(
            context.read<CareerSearchApiService>(),
          ),
        ),

        RepositoryProvider<CareerHomeRepository>(
          create: (context) => CareerHomeRepository(
            context.read<CareerHomeApiService>(),
          ),
        ),

        RepositoryProvider<CareerChildNodesRepository>(
          create: (context) => CareerChildNodesRepository(
            context.read<CareerChildNodesApiService>(),
          ),
        ),

      ],
      child: MultiBlocProvider(
        providers: [
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

          BlocProvider<SavedCollegeBloc>(
            create: (context) => SavedCollegeBloc(
              context.read<SavedCollegeRepository>(),
            ),
          ),

          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              context.read<ProfileRepository>(),
            ),
          ),

          BlocProvider<SavedCollegesListBloc>(
            create: (context) => SavedCollegesListBloc(
              context.read<SavedCollegesListRepository>(),
            ),
          ),

          BlocProvider<ChangePasswordBloc>(
            create: (context) => ChangePasswordBloc(
              context.read<ChangePasswordRepository>(),
            ),
          ),

          BlocProvider<CareerBannerBloc>(
            create: (context) => CareerBannerBloc(
              context.read<CareerBannerRepository>(),
            ),
          ),

          BlocProvider<CareerSearchBloc>(
            create: (context) => CareerSearchBloc(
              context.read<CareerSearchRepository>(),
            ),
          ),

          BlocProvider<CareerHomeBloc>(
            create: (context) => CareerHomeBloc(
              context.read<CareerHomeRepository>(),
            ),
          ),

          BlocProvider<CareerChildNodesBloc>(
            create: (context) => CareerChildNodesBloc(
              context.read<CareerChildNodesRepository>(),
            ),
          ),
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
