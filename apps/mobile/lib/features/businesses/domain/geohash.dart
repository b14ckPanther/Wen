import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
const _bits = [16, 8, 4, 2, 1];

class GeoHashQueryBounds {
  const GeoHashQueryBounds(this.start, this.end);

  final String start;
  final String end;
}

class GeoHashHelper {
  const GeoHashHelper._();

  static String encode(double latitude, double longitude, {int precision = 9}) {
    final latRange = [-90.0, 90.0];
    final lonRange = [-180.0, 180.0];
    final buffer = StringBuffer();
    var bits = 0;
    var bit = 0;
    var evenBit = true;

    while (buffer.length < precision) {
      if (evenBit) {
        final mid = (lonRange[0] + lonRange[1]) / 2;
        if (longitude >= mid) {
          bits |= _bits[bit];
          lonRange[0] = mid;
        } else {
          lonRange[1] = mid;
        }
      } else {
        final mid = (latRange[0] + latRange[1]) / 2;
        if (latitude >= mid) {
          bits |= _bits[bit];
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      evenBit = !evenBit;
      if (bit < 4) {
        bit++;
      } else {
        buffer.write(_base32[bits]);
        bit = 0;
        bits = 0;
      }
    }
    return buffer.toString();
  }

  static int precisionForRadiusKm(double radiusKm) {
    final radiusMeters = radiusKm * 1000;
    if (radiusMeters <= 610) return 9;
    if (radiusMeters <= 2400) return 8;
    if (radiusMeters <= 20000) return 6;
    if (radiusMeters <= 78000) return 5;
    if (radiusMeters <= 630000) return 4;
    return 3;
  }

  static GeoHashQueryBounds boundsFor(GeoPoint center, double radiusKm) {
    final precision = precisionForRadiusKm(radiusKm);
    final hash = encode(
      center.latitude,
      center.longitude,
      precision: precision,
    );
    return GeoHashQueryBounds(hash, '$hash~');
  }

  static bool isWithinRadius({
    required GeoPoint center,
    required GeoPoint candidate,
    required double radiusKm,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(candidate.latitude - center.latitude);
    final dLon = _degreesToRadians(candidate.longitude - center.longitude);

    final lat1 = _degreesToRadians(center.latitude);
    final lat2 = _degreesToRadians(candidate.latitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;
    return distanceKm <= radiusKm;
  }

  static double _degreesToRadians(double degrees) => degrees * (pi / 180.0);
}
