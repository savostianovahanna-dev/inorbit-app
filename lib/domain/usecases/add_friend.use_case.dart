import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../entities/friend.dart';
import '../repositories/friend_repository.dart';
import '../../core/services/cloudinary_service.dart';

class AddFriendParams {
  final String name;
  final String? avatarFilePath;
  final int? planetIndex;
  final DateTime? birthday;
  final bool remindBirthday;
  final String? notes;
  final String orbitTier;
  final int frequencyDays;
  final DateTime? lastConnectedAt;

  const AddFriendParams({
    required this.name,
    this.avatarFilePath,
    this.planetIndex,
    this.birthday,
    this.remindBirthday = true,
    this.notes,
    required this.orbitTier,
    required this.frequencyDays,
    this.lastConnectedAt,
  });
}

class AddFriendUseCase {
  final FriendRepository _repository;
  final CloudinaryService _cloudinary;

  AddFriendUseCase(this._repository, this._cloudinary);

  Future<Friend> call(AddFriendParams params) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final friendId = const Uuid().v4();

    String? avatarPath;
    String? avatarUrl;
    if (params.avatarFilePath != null) {
      debugPrint('Uploading avatar: ${params.avatarFilePath}');
      avatarUrl = await _cloudinary.uploadFriendAvatar(
        userId: userId,
        friendId: friendId,
        image: File(params.avatarFilePath!),
      );
      debugPrint('Avatar URL: $avatarUrl');
      avatarPath = params.avatarFilePath;
    }

    final friend = Friend(
      id: friendId,
      name: params.name,
      avatarPath: avatarPath,
      planetIndex: params.planetIndex,
      birthday: params.birthday,
      remindBirthday: params.remindBirthday,
      notes: params.notes,
      orbitTier: params.orbitTier,
      frequencyDays: params.frequencyDays,
      lastConnectedAt: params.lastConnectedAt,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
    );

    await _repository.addFriend(friend);
    return friend;
  }
}
