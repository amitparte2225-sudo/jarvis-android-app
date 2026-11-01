import 'package:flutter/material.dart';
import 'package:jarvis_app/core/auth/auth_controller.dart';
import 'package:jarvis_app/features/home/planned_feature_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.auth});
  final AuthController auth;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    PlannedFeaturePage(
      title: 'Ask JARVIS',
      icon: Icons.chat_bubble_outline,
      step: 3,
      description: 'Chat with JARVIS using Claude.',
    ),
    PlannedFeaturePage(
      title: 'Daily Revision',
      icon: Icons.replay,
      step: 5,
      description: 'Flashcards, spaced repetition, streaks and mistake notebook.',
    ),
    PlannedFeaturePage(
      title: 'Interview',
      icon: Icons.record_voice_over_outlined,
      step: 7,
      description: 'Mock interviews with scores and ideal answers.',
    ),
    PlannedFeaturePage(
      title: 'Exams',
      icon: Icons.school_outlined,
      step: 8,
      description: 'Syllabus, tests, mock exams and weak topics.',
    ),
    PlannedFeaturePage(
      title: 'More',
      icon: Icons.grid_view,
      step: 6,
      description: 'Documents, memory, tasks, progress and settings.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JARVIS'),
        actions: [
          IconButton(
            tooltip: 'Lock',
            icon: const Icon(Icons.lock_outline),
            onPressed: widget.auth.lock,
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Ask'),
          NavigationDestination(icon: Icon(Icons.replay), label: 'Revise'),
          NavigationDestination(icon: Icon(Icons.record_voice_over_outlined), label: 'Interview'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Exams'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'More'),
        ],
      ),
    );
  }
}
