import 'dart:convert';

import 'package:http/http.dart' as http;

/// Sends contact-form messages through Formspree (https://formspree.io), which
/// forwards them to the owner's inbox. No backend of our own is needed.
class FormspreeClient {
  FormspreeClient(this.formId, {http.Client? client})
    : _client = client ?? http.Client();

  /// The ID from the form endpoint `https://formspree.io/f/<formId>`.
  final String formId;
  final http.Client _client;

  /// Throws [FormspreeException] when the message was not accepted.
  Future<void> send({
    required String name,
    required String email,
    required String message,
  }) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('https://formspree.io/f/$formId'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email, // Formspree uses it as the reply-to address.
              'message': message,
              '_subject': 'Portfolio contact — $name',
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw FormspreeException('Network error: $e');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FormspreeException(
        'Formspree returned ${response.statusCode}: ${response.body}',
      );
    }
  }
}

class FormspreeException implements Exception {
  const FormspreeException(this.message);
  final String message;

  @override
  String toString() => 'FormspreeException: $message';
}
