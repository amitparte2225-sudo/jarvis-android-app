import 'package:flutter/material.dart';
import 'package:jarvis_app/core/auth/auth_controller.dart';
import 'package:jarvis_app/features/auth/pin_field.dart';

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key, required this.auth});
  final AuthController auth;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _pin = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _pin.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await widget.auth.unlock(_pin.text);
      if (!mounted) return;
      if (!r.ok) {
        _pin.clear();
        setState(() {
          _error = r.lockedFor != null
              ? 'Too many wrong tries. Wait ${r.lockedFor!.inSeconds + 1} seconds.'
              : 'Wrong PIN. ${r.attemptsLeft} tries left.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 16),
                  Text('JARVIS is locked',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  PinField(
                    controller: _pin,
                    label: 'Enter PIN',
                    autofocus: true,
                    onSubmitted: _submit,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Unlock'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
