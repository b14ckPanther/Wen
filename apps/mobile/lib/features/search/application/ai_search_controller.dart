import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import '../data/models/ai_search_result.dart';
import '../data/repositories/ai_search_repository.dart';

final aiSearchRepositoryProvider = Provider<AiSearchRepository>((ref) {
  return AiSearchRepository();
});

final aiSearchControllerProvider =
    legacy.StateNotifierProvider.autoDispose<
      AiSearchController,
      AsyncValue<List<AiSearchResult>>
    >((ref) => AiSearchController(ref.watch(aiSearchRepositoryProvider)));

class AiSearchController
    extends StateNotifier<AsyncValue<List<AiSearchResult>>> {
  AiSearchController(this._repository) : super(const AsyncValue.data([]));

  final AiSearchRepository _repository;

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    try {
      final results = await _repository.fetchSuggestions(query: query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
