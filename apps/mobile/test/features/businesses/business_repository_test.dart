import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/businesses/data/repositories/business_repository.dart';

void main() {
  group('BusinessRepository.buildSearchKeywords', () {
    test('normalises tokens, strips punctuation, and removes short words', () {
      final keywords = BusinessRepository.buildSearchKeywords([
        'Al Madina Bistro',
        'Modern Emirati fusion cuisine.',
        'restaurants',
      ]);

      expect(
        keywords,
        containsAll(<String>[
          'al',
          'madina',
          'bistro',
          'modern',
          'emirati',
          'fusion',
          'cuisine',
          'restaurants',
        ]),
      );
      expect(keywords.any((token) => token.length == 1), isFalse);
    });

    test('deduplicates tokens across sources', () {
      final keywords = BusinessRepository.buildSearchKeywords([
        'Palm Beauty',
        'Beauty lounge',
      ]);

      final beautyOccurrences = keywords.where((token) => token == 'beauty');
      expect(beautyOccurrences.length, 1);
    });
  });
}
