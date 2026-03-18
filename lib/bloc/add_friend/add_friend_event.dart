import 'package:inorbit/domain/usecases/add_friend.use_case.dart';

abstract class AddFriendEvent {}

class AddFriendSubmitted extends AddFriendEvent {
  final AddFriendParams params;
  AddFriendSubmitted(this.params);
}
