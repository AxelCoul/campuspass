import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MainTabBar extends StatelessWidget {
  const MainTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabItem(
            index: 0,
            icon: Icons.home_outlined,
            label: 'Accueil',
            isActive: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _TabItem(
            index: 1,
            icon: Icons.search,
            label: 'Explorer',
            isActive: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _TabItem(
            index: 2,
            icon: Icons.savings_outlined,
            label: 'Économie',
            isActive: currentIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _TabItem(
            index: 3,
            icon: Icons.favorite_border,
            label: 'Favoris',
            isActive: currentIndex == 3,
            onTap: () => onTabSelected(3),
          ),
          _TabItem(
            index: 4,
            icon: Icons.person_outline,
            label: 'Profil',
            isActive: currentIndex == 4,
            onTap: () => onTabSelected(4),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.primary
        : AppColors.secondary.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption(context).copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

