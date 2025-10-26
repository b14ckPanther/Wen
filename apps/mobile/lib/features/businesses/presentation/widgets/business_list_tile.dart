import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Uri? get _phoneUri {
    final phone = business.phoneNumber;
    if (phone == null || phone.isEmpty) return null;
    return Uri(scheme: 'tel', path: phone);
  }

  Uri? get _whatsappUri {
    final whatsapp = business.whatsappNumber;
    if (whatsapp == null || whatsapp.isEmpty) return null;
    final normalised = whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
    return Uri.parse('https://wa.me/${normalised.replaceAll('+', '')}');
  }

  Uri get _mapsUri => Uri.parse(business.googleMapsUrl());

  Future<void> _launchUri(BuildContext context, Uri? uri) async {
    if (uri == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Could not open ${uri.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distanceLabel = distanceKm != null
        ? '${distanceKm!.toStringAsFixed(1)} km'
        : null;
    final phoneUri = _phoneUri;
    final whatsappUri = _whatsappUri;

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
            if (phoneUri != null)
              IconButton(
                icon: const Icon(Icons.call),
                tooltip: 'Call',
                onPressed: () => _launchUri(context, phoneUri),
              ),
            if (whatsappUri != null)
              IconButton(
                icon: const Icon(Icons.chat_outlined),
                tooltip: 'WhatsApp',
                onPressed: () => _launchUri(context, whatsappUri),
              ),
            if (onViewOnMap != null)
              IconButton(
                icon: const Icon(Icons.map_outlined),
                tooltip: 'View on map',
                onPressed: onViewOnMap,
              ),
            if (onViewOnMap == null)
              IconButton(
                icon: const Icon(Icons.place_outlined),
                tooltip: 'Directions',
                onPressed: () => _launchUri(context, _mapsUri),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
