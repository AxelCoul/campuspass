import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FilterPillChip extends StatelessWidget {
  const FilterPillChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final parts = label.trim().split(' ');
    final emoji = parts.isNotEmpty ? parts.first : '';
    final text = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // Quand le chip n’est pas sélectionné, on met un fond légèrement teinté
    // pour que l’emoji reste bien visible (notamment si le texte est masqué).
    final bgColor = isSelected
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.10);
    final borderColor = isSelected
        ? Colors.transparent
        : AppColors.primary.withValues(alpha: 0.22);
    final textColor = isSelected ? Colors.white : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji.isNotEmpty)
                Text(
                  emoji,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              if (text.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  text,
                  style: AppTextStyles.caption(context).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

