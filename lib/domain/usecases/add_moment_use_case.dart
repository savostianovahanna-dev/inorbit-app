import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/cloudinary_service.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';

/// Uploads any local photo files to Cloudinary, then persists the moment
/// with the resulting URLs so photos are available across devices.
class AddMomentUseCase {
  AddMomentUseCase(this._repository, this._cloudinary);

  final MomentRepository _repository;
  final CloudinaryService _cloudinary;

  Future<void> call(Moment moment) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final uploadedUrls = <String>[];
    for (int i = 0; i < moment.photoPaths.length; i++) {
      final path = moment.photoPaths[i];
      // Already a remote URL — keep as-is.
      if (path.startsWith('http')) {
        uploadedUrls.add(path);
      } else {
        final url = await _cloudinary.uploadMomentPhoto(
          userId: userId,
          momentId: moment.id,
          filename: 'photo_$i',
          image: File(path),
        );
        uploadedUrls.add(url);
      }
    }

    final withUrls = Moment(
      id: moment.id,
      friendId: moment.friendId,
      type: moment.type,
      customType: moment.customType,
      date: moment.date,
      note: moment.note,
      photoPaths: List.unmodifiable(uploadedUrls),
      createdAt: moment.createdAt,
    );

    await _repository.addMoment(withUrls);
  }
}
