import 'package:flutter/material.dart';
import 'package:jarvis_app/core/auth/auth_controller.dart';
import 'package:jarvis_app/core/auth/pin_service.dart';
import 'package:jarvis_app/features/auth/pin_field.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key, required this.auth});
  final AuthController auth;

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final pin = _pin.text;
    if (!PinService.isValidFormat(pin)) {
      setState(() => _error = 'Use 4 to 8 digits.');
      return;
    }
    if (PinService.isTooWeak(pin)) {
      setState(() => _error = 'Too easy. Do not repeat one digit.');
      return;
    }
    if (pin != _confirm.text) {
      setState(() => _error = 'The two PINs do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.createPin(pin);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save the PIN. Please try again.');
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
                  const Icon(Icons.shield_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text('Create your PIN',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'This PIN protects JARVIS on this phone. Use 4 to 8 digits.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PinField(controller: _pin, label: 'New PIN', autofocus: true),
                  const SizedBox(height: 16),
                  PinField(
                    controller: _confirm,
                    label: 'Type the PIN again',
                    onSubmitted: _save,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save PIN'),
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
