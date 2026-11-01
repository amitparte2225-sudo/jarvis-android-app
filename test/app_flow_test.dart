
import 'package:flutter/material.dart';
import 'package:jarvis_app/core/services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _gemini = GeminiService();

  final TextEditingController _controller =
      TextEditingController();

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });

      _isLoading = true;
    });

    _controller.clear();

    try {
      final reply = await _gemini.sendMessage(message);

      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'jarvis',
          'text': reply,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'jarvis',
          'text': 'Sorry, something went wrong: $e',
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Ask JARVIS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text(
                    'Hello! I am JARVIS.\nHow can I help you today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];

                    final isUser =
                        message['role'] == 'user';

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['text'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask JARVIS anything...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed:
                      _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
