import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/friend.dart';

class FriendAvatar extends StatelessWidget {
  const FriendAvatar({super.key, required this.friend, this.size = 44});

  final Friend friend;
  final double size;

  static const _planets = [
    'assets/images/planets/planet_1.png',
    'assets/images/planets/planet_2.png',
    'assets/images/planets/planet_3.png',
    'assets/images/planets/planet_4.png',
    'assets/images/planets/planet_5.png',
    'assets/images/planets/planet_6.png',
    'assets/images/planets/planet_7.png',
    'assets/images/planets/planet_8.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(child: _buildImage()),
    );
  }

  Widget _buildImage() {
    if (friend.avatarPath != null && File(friend.avatarPath!).existsSync()) {
      return Image.file(
        File(friend.avatarPath!),
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }

    if (friend.avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: friend.avatarUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeholder: (_, __) => _initialsWidget(),
        errorWidget: (_, __, ___) => _initialsWidget(),
      );
    }

    if (friend.planetIndex != null) {
      final index = friend.planetIndex! - 1;
      if (index >= 0 && index < _planets.length) {
        return Image.asset(
          _planets[index],
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      }
    }

    return _initialsWidget();
  }

  Widget _initialsWidget() {
    final initials =
        friend.name.isNotEmpty
            ? friend.name
                .trim()
                .split(' ')
                .map((w) => w[0].toUpperCase())
                .take(2)
                .join()
            : '?';

    return Container(
      width: size,
      height: size,
      color: const Color(0xFF1E3A6E),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
