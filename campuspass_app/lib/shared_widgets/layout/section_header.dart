import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.actionLabel,
    this.onActionTap,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
  });

  final String title;
  final IconData? leadingIcon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h2(context),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: onActionTap != null
                  ? HitTestBehavior.opaque
                  : HitTestBehavior.deferToChild,
              child: Text(
                actionLabel!,
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

