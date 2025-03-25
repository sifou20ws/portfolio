import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/locale_keys.dart';

/// Opens external links (stores, GitHub, mailto…) and reports failures with a
/// snackbar instead of throwing.
abstract final class LinkLauncher {
  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    var ok = false;
    if (uri != null) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        ok = false;
      }
    }
    if (!ok) {
      AppSnackbar.show(
        LocaleKeys.linkError.trParams({'url': url}),
        isError: true,
      );
    }
    return ok;
  }

  static Future<bool> email(String to, {String? subject, String? body}) {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      // `queryParameters` encodes spaces as '+', which mail clients show
      // literally, so build the query by hand with %20 encoding.
      query: _encodeQuery({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );
    return open(uri.toString());
  }

  static String? _encodeQuery(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

/// Themed floating snackbar reachable from controllers (no BuildContext).
abstract final class AppSnackbar {
  static void show(String message, {String? title, bool isError = false}) {
    final context = Get.context;
    if (context == null) return;
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError
              ? colors.errorContainer
              : colors.inverseSurface,
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError
                    ? colors.onErrorContainer
                    : colors.onInverseSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title == null ? message : '$title  $message',
                  style: TextStyle(
                    color: isError
                        ? colors.onErrorContainer
                        : colors.onInverseSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
