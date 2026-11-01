import 'package:flutter/material.dart';
import 'package:jarvis_app/core/auth/auth_controller.dart';
import 'package:jarvis_app/core/theme.dart';
import 'package:jarvis_app/features/auth/setup_pin_screen.dart';
import 'package:jarvis_app/features/auth/unlock_screen.dart';
import 'package:jarvis_app/features/home/home_shell.dart';

class JarvisApp extends StatefulWidget {
  const JarvisApp({super.key, required this.auth});
  final AuthController auth;

  @override
  State<JarvisApp> createState() => _JarvisAppState();
}

class _JarvisAppState extends State<JarvisApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.auth.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.auth.onBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      widget.auth.onResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: ListenableBuilder(
        listenable: widget.auth,
        builder: (context, _) {
          switch (widget.auth.status) {
            case AuthStatus.loading:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AuthStatus.needsSetup:
              return SetupPinScreen(auth: widget.auth);
            case AuthStatus.locked:
              return UnlockScreen(auth: widget.auth);
            case AuthStatus.unlocked:
              return HomeShell(auth: widget.auth);
          }
        },
      ),
    );
  }
}
