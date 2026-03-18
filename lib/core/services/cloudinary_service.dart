import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  static String get _apiKey => dotenv.env['CLOUDINARY_API_KEY']!;
  static String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET']!;

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // ── Public methods ────────────────────────────────────────────────────────

  /// Upload avatar for a friend. Returns Cloudinary URL.
  Future<String> uploadFriendAvatar({
    required String userId,
    required String friendId,
    required File image,
  }) async {
    final publicId = 'users/$userId/avatars/$friendId';
    return _upload(file: image, publicId: publicId);
  }

  /// Upload a photo for a moment. Returns Cloudinary URL.
  Future<String> uploadMomentPhoto({
    required String userId,
    required String momentId,
    required String filename,
    required File image,
  }) async {
    final publicId = 'users/$userId/moments/$momentId/$filename';
    return _upload(file: image, publicId: publicId);
  }

  /// Delete a photo by its Cloudinary URL.
  Future<void> deletePhoto(String url) async {
    final publicId = _extractPublicId(url);
    if (publicId == null) return;

    final timestamp = _timestamp();
    final signature = _sign('public_id=$publicId&timestamp=$timestamp');

    await http.post(
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy'),
      body: {
        'public_id': publicId,
        'timestamp': timestamp,
        'api_key': _apiKey,
        'signature': signature,
      },
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<String> _upload({required File file, required String publicId}) async {
    final timestamp = _timestamp();
    final signature = _sign(
      'overwrite=true&public_id=$publicId&timestamp=$timestamp',
    );

    final request =
        http.MultipartRequest('POST', Uri.parse(_uploadUrl))
          ..fields['api_key'] = _apiKey
          ..fields['timestamp'] = timestamp
          ..fields['public_id'] = publicId
          ..fields['overwrite'] = 'true'
          ..fields['signature'] = signature
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  String _timestamp() =>
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  String _sign(String params) {
    final toSign = '$params$_apiSecret';
    return sha256.convert(utf8.encode(toSign)).toString();
  }

  String? _extractPublicId(String url) {
    // https://res.cloudinary.com/cloud/image/upload/v123/users/uid/avatars/fid.jpg
    // → users/uid/avatars/fid
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1) return null;
      // skip version segment (v1234567890)
      final afterUpload = segments.sublist(uploadIndex + 1);
      final withoutVersion =
          afterUpload.first.startsWith('v')
              ? afterUpload.sublist(1)
              : afterUpload;
      final joined = withoutVersion.join('/');
      // remove extension
      final dotIndex = joined.lastIndexOf('.');
      return dotIndex != -1 ? joined.substring(0, dotIndex) : joined;
    } catch (_) {
      return null;
    }
  }
}
