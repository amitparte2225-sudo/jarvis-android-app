```dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://jarvis-android-app.onrender.com';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 90));

      print('JARVIS STATUS: ${response.statusCode}');
      print('JARVIS RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['reply'] != null) {
          return data['reply'].toString();
        }

        throw Exception('Reply field missing in server response.');
      }

      throw Exception(
        'Server error: ${response.statusCode} - ${response.body}',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on SocketException catch (e) {
      throw Exception('Network connection failed: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid server response: $e');
    } catch (e) {
      throw Exception('JARVIS error: $e');
    }
  }
}
```
