import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Profile section widget for grouping related settings
class ProfileSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSectionWidget({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
