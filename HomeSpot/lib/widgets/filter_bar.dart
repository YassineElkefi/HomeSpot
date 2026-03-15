import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterOption {
  final String label;
  final String value;
  const FilterOption({required this.label, required this.value});
}

class FilterBar extends StatelessWidget {
  final List<FilterOption> filters;
  final String activeValue;
  final void Function(String) onSelect;

  const FilterBar({
    super.key,
    required this.filters,
    required this.activeValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final isActive = f.value == activeValue;

          return GestureDetector(
            onTap: () => onSelect(f.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive ? null : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryDark
                      : AppColors.cardBorder,
                  width: 1,
                ),
                boxShadow: isActive ? AppShadows.goldGlow : null,
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.background : AppColors.textSecondary,
                  letterSpacing: isActive ? 0.3 : 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}