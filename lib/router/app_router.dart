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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/bloc/signup/signup_bloc.dart';
import 'package:careers/data/repositories/auth_repository.dart';

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
          // Parse tab from query parameters, default to 0 (Home)
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
            child: CourseDetailScreen(courseData: courseData),
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

      // College Details Screen - UPDATED TO USE COLLEGE ID
      GoRoute(
        path: '/college-details',
        name: 'college-details',
        pageBuilder: (context, state) {
          final collegeId = state.extra as String; // Changed from Map to String
          return CustomTransitionPage(
            key: state.pageKey,
            child: CollegeDetailsPage(collegeId: collegeId), // Pass ID instead of college object
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
    ],
  );
}