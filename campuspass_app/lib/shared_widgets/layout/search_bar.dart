import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SearchBarHome extends StatelessWidget {
  const SearchBarHome({
    super.key,
    required this.placeholder,
    this.onTap,
    this.onChanged,
    this.outerPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String placeholder;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  /// Marge autour de la barre (réduire le bas sur Explorer pour rapprocher les onglets).
  final EdgeInsetsGeometry outerPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: outerPadding,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: AppColors.secondary.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onTap: onTap,
                onChanged: onChanged,
                style: AppTextStyles.body(context),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: AppTextStyles.bodySecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

