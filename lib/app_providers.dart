import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/api/auth_api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../utils/prefs/auth_local_storage.dart';
import 'data/repositories/admission_banner_repository.dart';
import 'data/api/admission_banner_api.dart';
import 'data/api/college_api_service.dart';
import 'data/repositories/college_repository.dart';

class AppProviders {
  static List<RepositoryProvider> get repositories => [
    // Auth Local Storage (must be first as others depend on it)
    RepositoryProvider<AuthLocalStorage>(
      create: (_) => AuthLocalStorage(),
    ),

    // Auth Services
    RepositoryProvider<AuthApiService>(
      create: (_) => AuthApiService(),
    ),
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepository(
        context.read<AuthApiService>(),
        context.read<AuthLocalStorage>(),
      ),
    ),

    // Admission Banner Services
    RepositoryProvider<AdmissionApiService>(
      create: (_) => AdmissionApiService(),
    ),
    RepositoryProvider<AdmissionRepository>(
      create: (context) => AdmissionRepository(
        context.read<AdmissionApiService>(),
      ),
    ),

    // College Services (with Auth)
    RepositoryProvider<CollegeApiService>(
      create: (context) => CollegeApiService(
        context.read<AuthLocalStorage>(), // Pass auth storage
      ),
    ),
    RepositoryProvider<CollegeRepository>(
      create: (context) => CollegeRepository(
        context.read<CollegeApiService>(),
      ),
    ),
  ];
}