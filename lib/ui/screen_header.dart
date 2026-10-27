import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import 'avatar_circle.dart';

/// Back arrow (only when there is somewhere to go back to), avatar, and the
/// large screen title used on the light screens.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.showAvatar = true,
    this.trailing,
  });

  final String title;
  final bool showAvatar;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                if (canPop)
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.chevron_left, size: 32),
                    color: AppColors.ink,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                const Spacer(),
                trailing ??
                    (showAvatar
                        ? const AvatarCircle(initial: 'N')
                        : const SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
