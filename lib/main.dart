import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inorbit/domain/usecases/sync_data.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  setupDependencies();
  await NotificationService.instance.init();
final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    initRemoteRepositories(currentUser.uid);
    getIt<SyncData>().call().catchError((Object e) {
      debugPrint('Startup sync failed: $e');
    });
  }
  runApp(const InOrbitApp());
}
