import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/api/auth_api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../utils/prefs/auth_local_storage.dart';

class AppProviders {
  static List<RepositoryProvider> get repositories => [
    RepositoryProvider<AuthApiService>(
      create: (_) => AuthApiService(),
    ),
    RepositoryProvider<AuthLocalStorage>(
      create: (_) => AuthLocalStorage(),
    ),
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepository(
        context.read<AuthApiService>(),
        context.read<AuthLocalStorage>(),
      ),
    ),
  ];
}
