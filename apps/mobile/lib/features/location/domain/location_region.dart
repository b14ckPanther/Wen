import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mobile/l10n/app_localizations.dart';

class LocationRegion {
  const LocationRegion({
    required this.id,
    required this.nameKey,
    required this.center,
    required this.defaultRadiusKm,
  });

  final String id;
  final String nameKey;
  final GeoPoint center;
  final double defaultRadiusKm;

  String label(AppLocalizations l10n) {
    switch (nameKey) {
      case 'north':
        return l10n.regionNorth;
      case 'south':
        return l10n.regionSouth;
      case 'east':
        return l10n.regionEast;
      case 'west':
        return l10n.regionWest;
      case 'center':
      default:
        return l10n.regionCenter;
    }
  }
}

const presetRegions = <LocationRegion>[
  LocationRegion(
    id: 'north',
    nameKey: 'north',
    center: GeoPoint(32.7940, 35.5312), // Haifa
    defaultRadiusKm: 25,
  ),
  LocationRegion(
    id: 'center',
    nameKey: 'center',
    center: GeoPoint(31.7683, 35.2137), // Jerusalem
    defaultRadiusKm: 20,
  ),
  LocationRegion(
    id: 'south',
    nameKey: 'south',
    center: GeoPoint(29.5581, 34.9482), // Eilat
    defaultRadiusKm: 30,
  ),
  LocationRegion(
    id: 'east',
    nameKey: 'east',
    center: GeoPoint(33.5104, 36.2783), // Damascus placeholder
    defaultRadiusKm: 40,
  ),
  LocationRegion(
    id: 'west',
    nameKey: 'west',
    center: GeoPoint(30.0444, 31.2357), // Cairo placeholder
    defaultRadiusKm: 50,
  ),
];
