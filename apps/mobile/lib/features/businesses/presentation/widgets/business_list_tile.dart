import 'package:flutter/material.dart';

import '../../data/models/business.dart';

class BusinessListTile extends StatelessWidget {
  const BusinessListTile({
    super.key,
    required this.business,
    this.distanceKm,
    this.onTap,
    this.onViewOnMap,
  });

  final Business business;
  final double? distanceKm;
  final VoidCallback? onTap;
  final VoidCallback? onViewOnMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distanceLabel = distanceKm != null
        ? '${distanceKm!.toStringAsFixed(1)} km'
        : null;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          foregroundColor: theme.colorScheme.primary,
          child: Text(
            business.name.isNotEmpty ? business.name[0].toUpperCase() : '?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          business.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              business.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(business.plan.toUpperCase()),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                if (distanceLabel != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(distanceLabel),
                    ],
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onViewOnMap != null)
              IconButton(
                icon: const Icon(Icons.map_outlined),
                tooltip: 'View on map',
                onPressed: onViewOnMap,
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
