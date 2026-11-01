import 'package:flutter/material.dart';
import 'package:jarvis_app/app.dart';
import 'package:jarvis_app/core/auth/auth_controller.dart';
import 'package:jarvis_app/core/auth/pin_service.dart';
import 'package:jarvis_app/core/auth/secure_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthController(PinService(FlutterSecureStore()));
  runApp(JarvisApp(auth: auth));
}
