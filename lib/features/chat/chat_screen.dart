import 'package:flutter/material.dart';
import 'package:jarvis_app/core/services/gemini_service.dart';
import 'package:jarvis_app/core/services/database_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _gemini = GeminiService();
  final DatabaseService _database = DatabaseService.instance;

  final TextEditingController _controller =
      TextEditingController();

  final List<Map<String, String>> _messages = [];

  int? _conversationId;

  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final id = await _database.createConversation('New Chat');

      if (!mounted) return;

      setState(() {
        _conversationId = id;
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty ||
        _isLoading ||
        _conversationId == null) {
      return;
    }

    final conversationId = _conversationId!;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });
      _isLoading = true;
    });

    _controller.clear();

    try {
      await _database.saveMessage(
        conversationId,
        'user',
        message,
      );

      final reply = await _gemini.sendMessage(message);

      await _database.saveMessage(
        conversationId,
        'jarvis',
        reply,
      );

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
          'text': 'Sorry, error: $e',
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
          child: _isInitializing
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Hello! I am JARVIS.\n'
                        'How can I help you today?',
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
                            constraints:
                                const BoxConstraints(maxWidth: 300),
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
                    enabled: !_isInitializing &&
                        _conversationId != null &&
                        !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Ask JARVIS anything...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (_isLoading ||
                          _isInitializing ||
                          _conversationId == null)
                      ? null
                      : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
