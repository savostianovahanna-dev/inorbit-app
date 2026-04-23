import '../../core/services/auth_service.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._authService);

  final AuthService _authService;

  Future<void> call() => _authService.deleteAccount();
}
