import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/search/data/repositories/ai_search_repository.dart';

void main() {
  test('AI search repository returns mock suggestions', () async {
    final repository = AiSearchRepository();

    final results = await repository.fetchSuggestions(query: 'Coffee in Dubai');

    expect(results, isNotEmpty);
    expect(results.first.summary.toLowerCase(), contains('dubai'));
  });
}
