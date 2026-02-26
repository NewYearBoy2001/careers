import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/screens/splash_screen.dart';
import 'package:careers/screens/login_screen.dart';
import 'package:careers/screens/signup_screen.dart';
import 'package:careers/screens/dashboard_screen.dart';
import 'package:careers/screens/home/aptitude_test_page.dart';
import 'package:careers/screens/home/aptitude_result_page.dart';
import 'package:careers/screens/careers/course_detail_screen.dart';
import 'package:careers/screens/admission/college_details_page.dart';
import 'package:careers/screens/admission/college_search_results_page.dart'; // ✅ ADD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/bloc/signup/signup_bloc.dart';
import 'package:careers/data/repositories/auth_repository.dart';
import 'package:careers/screens/profile/saved_colleges_page.dart';
import 'package:careers/screens/profile/edit_profile_screen.dart';
import 'package:careers/data/models/profile_model.dart';
import 'package:careers/screens/profile/change_password_screen.dart';
import 'package:careers/bloc/change_password/change_password_bloc.dart';
import 'package:careers/data/repositories/change_password_repository.dart';
import 'package:careers/bloc/career_search/career_search_bloc.dart';
import 'package:careers/data/repositories/career_search_repository.dart';
import 'package:careers/screens/careers/career_search_results_page.dart';
import 'package:careers/screens/careers/career_child_nodes_page.dart';
import 'package:careers/bloc/career_child_nodes/career_child_nodes_bloc.dart';
import 'package:careers/data/repositories/career_child_nodes_repository.dart';
import 'package:careers/screens/forgot_password_screen.dart';
import 'package:careers/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:careers/data/repositories/forgot_password_repository.dart';
import 'package:careers/data/api/forgot_password_api_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),

      // Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => SignupBloc(
              repository: context.read<AuthRepository>(),
            ),
            child: const SignupScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
        ),
      ),

      // Dashboard Screen with tab parameter
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) {
          final tabIndex = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return CustomTransitionPage(
            key: state.pageKey,
            child: DashboardScreen(initialTab: tabIndex),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),

      // Aptitude Test Screen
      GoRoute(
        path: '/aptitude-test',
        name: 'aptitude-test',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AptitudeTestPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      // Aptitude Result Screen
      GoRoute(
        path: '/aptitude-result',
        name: 'aptitude-result',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AptitudeResultPage(
              scores: extra['scores'] as Map<String, int>,
              topCareers: extra['topCareers'] as List<String>,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),

      // Course Detail Screen
      GoRoute(
        path: '/course-detail',
        name: 'course-detail',
        pageBuilder: (context, state) {
          final courseData = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CourseDetailScreen(courseData: courseData),  // ✅ Should work as-is
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      /// ✅ UPDATE: College Search Results Screen
      GoRoute(
        path: '/college-search',
        name: 'college-search',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, String?>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CollegeSearchResultsPage(
              initialKeyword: extra?['keyword'],
              initialLocation: extra?['location'],
              focusField: extra?['focusField'], // ✅ ADD: Pass focus field
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      // College Details Screen
      GoRoute(
        path: '/college-details',
        name: 'college-details',
        pageBuilder: (context, state) {
          final collegeId = state.extra as String;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CollegeDetailsPage(collegeId: collegeId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/saved-colleges',
        name: 'saved-colleges',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SavedCollegesPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        pageBuilder: (context, state) {
          final profile = state.extra as ProfileModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditProfileScreen(profile: profile),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/change-password',
        name: 'change-password',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => ChangePasswordBloc(
                context.read<ChangePasswordRepository>(),
              ),
              child: const ChangePasswordScreen(),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/career-search',
        name: 'career-search',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, String?>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => CareerSearchBloc(
                context.read<CareerSearchRepository>(),
              ),
              child: CareerSearchResultsPage(
                initialKeyword: extra?['keyword'],
                initialLocation: extra?['location'],
                focusField: extra?['focusField'],
              ),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/career-child-nodes',
        name: 'career-child-nodes',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => CareerChildNodesBloc(
                    context.read<CareerChildNodesRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => CareerSearchBloc(
                    context.read<CareerSearchRepository>(),
                  ),
                ),
              ],
              child: CareerChildNodesPage(
                parentId: extra['parentId']!.toString(),
                parentTitle: extra['parentTitle']!.toString(),
              ),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/forgot-password',  // ← must be exactly this, with hyphen
        name: 'forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => ForgotPasswordBloc(
              ForgotPasswordRepository(ForgotPasswordApiService()),
            ),
            child: const ForgotPasswordScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
        ),
      ),
    ],
  );
}