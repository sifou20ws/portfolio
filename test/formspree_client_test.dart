import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:portfolio/data/repositories/formspree_client.dart';

void main() {
  test('posts the message as JSON to the form endpoint', () async {
    late http.Request sent;
    final client = FormspreeClient(
      'abc123',
      client: MockClient((request) async {
        sent = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    await client.send(name: 'Ada', email: 'ada@example.com', message: 'Hello!');

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'https://formspree.io/f/abc123');
    expect(sent.headers['Accept'], 'application/json');
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body['name'], 'Ada');
    expect(body['email'], 'ada@example.com');
    expect(body['message'], 'Hello!');
  });

  test('throws when Formspree rejects the message', () async {
    final client = FormspreeClient(
      'abc123',
      client: MockClient((_) async => http.Response('{"error":"spam"}', 422)),
    );

    expect(
      () => client.send(name: 'A', email: 'a@b.co', message: 'x'),
      throwsA(isA<FormspreeException>()),
    );
  });

  test('throws on network failure', () async {
    final client = FormspreeClient(
      'abc123',
      client: MockClient((_) => throw http.ClientException('offline')),
    );

    expect(
      () => client.send(name: 'A', email: 'a@b.co', message: 'x'),
      throwsA(isA<FormspreeException>()),
    );
  });
}
