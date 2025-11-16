import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../data/models/project.dart';

/// Store / demo / repository buttons. Only links that exist are rendered;
/// the first available one gets the primary (filled) style.
class ProjectLinksBar extends StatelessWidget {
  const ProjectLinksBar({super.key, required this.links, required this.accent});

  final ProjectLinks links;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final entries = <({FaIconData icon, String label, String url})>[
      if (links.playStore != null)
        (
          icon: FontAwesomeIcons.googlePlay,
          label: LocaleKeys.linkPlayStore.tr,
          url: links.playStore!,
        ),
      if (links.appStore != null)
        (
          icon: FontAwesomeIcons.apple,
          label: LocaleKeys.linkAppStore.tr,
          url: links.appStore!,
        ),
      if (links.webDemo != null)
        (
          icon: FontAwesomeIcons.globe,
          label: LocaleKeys.linkWebDemo.tr,
          url: links.webDemo!,
        ),
      if (links.github != null)
        (
          icon: FontAwesomeIcons.github,
          label: LocaleKeys.linkGithub.tr,
          url: links.github!,
        ),
    ];

    if (entries.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: context.palette.mutedText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              LocaleKeys.detailNoLinks.tr,
              style: context.text.bodyMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < entries.length; i++)
          i == 0
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onColor(accent),
                  ),
                  onPressed: () => LinkLauncher.open(entries[i].url),
                  icon: FaIcon(entries[i].icon, size: 16),
                  label: Text(entries[i].label),
                )
              : OutlinedButton.icon(
                  onPressed: () => LinkLauncher.open(entries[i].url),
                  icon: FaIcon(entries[i].icon, size: 16),
                  label: Text(entries[i].label),
                ),
      ],
    );
  }
}
