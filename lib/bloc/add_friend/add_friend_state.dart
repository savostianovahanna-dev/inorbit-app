abstract class AddFriendState {}

class AddFriendInitial extends AddFriendState {}

class AddFriendLoading extends AddFriendState {}

class AddFriendSuccess extends AddFriendState {
  final String friendName;
  AddFriendSuccess(this.friendName);
}

class AddFriendError extends AddFriendState {
  final String message;
  AddFriendError(this.message);
}
