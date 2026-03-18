import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repository/auth_remote_repository.dart';
import 'package:client/features/auth/repository/local_remote_repo.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late LocalRemoteRepo _localRemoteRepo;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _localRemoteRepo = ref.watch(localRemoteRepoProvider);
    _currentUserNotifier = ref.watch(currentUserProvider.notifier);
    return null;
  }

  Future<void> initSharedPreference() async {
    await _localRemoteRepo.init();
  }

  Future<void> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.signUp(
      name: name,
      email: email,
      password: password,
    );

    switch (res) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
        break;
      case Right(value: final r):
        state = AsyncValue.data(r);
        break;
    }
  }

  Future<void> logInUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.logIn(
      email: email,
      password: password,
    );

    switch (res) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
        break;
      case Right(value: final r):
        state = _loginSuccess(r);
        break;
    }
  }

  AsyncValue<UserModel> _loginSuccess(UserModel user) {
    _localRemoteRepo.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();
    final token = _localRemoteRepo.getToken();
    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);
      final val = switch (res) {
        Left(value: final l) => state = AsyncValue.error(
          l.message,
          StackTrace.current,
        ),
        Right(value: final r) => _getSuccessData(r),
      };
      return val.value;
    }
    state = null;
    return null;
  }

  AsyncValue<UserModel> _getSuccessData(UserModel user) {
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }
}
