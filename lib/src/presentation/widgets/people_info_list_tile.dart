import 'package:flutter/material.dart';

class PeopleInfoListTile extends StatelessWidget {
  const PeopleInfoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.people_alt_outlined,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(radius) : Radius.zero,
          bottom: isLast ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          leadingIcon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: hasSubtitle
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
      ),
    );
  }
}
