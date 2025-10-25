import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ai_search_result.dart';

const bool _useRemoteAiSearch = bool.fromEnvironment(
  'USE_AI_SEARCH_API',
  defaultValue: false,
);
const String _aiSearchApiBaseUrl = String.fromEnvironment(
  'AI_SEARCH_BASE_URL',
  defaultValue: '',
);

class AiSearchRepository {
  AiSearchRepository({Dio? httpClient}) : _httpClient = httpClient ?? Dio();

  final Dio _httpClient;

  Future<List<AiSearchResult>> fetchSuggestions({required String query}) async {
    if (_useRemoteAiSearch && _aiSearchApiBaseUrl.isNotEmpty) {
      try {
        final token = await _currentUserToken();
        final response = await _httpClient.post<Map<String, dynamic>>(
          '$_aiSearchApiBaseUrl/v1/search',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
          data: {'query': query, 'top_k': 3},
        );

        final data = response.data;
        if (data == null) {
          throw const FormatException('Empty AI search response');
        }
        final results = (data['results'] as List<dynamic>? ?? [])
            .map(
              (item) => AiSearchResult(
                title: item['title'] as String? ?? 'Suggestion',
                summary: item['summary'] as String? ?? '',
                confidence: (item['confidence'] as num?)?.toDouble() ?? 0.0,
              ),
            )
            .toList();
        if (results.isNotEmpty) {
          return results;
        }
      } catch (error, stackTrace) {
        // Swallow and fall back to local stub for now.
        // ignore: avoid_print
        print(
          'AI search API failed, falling back to local suggestions: $error\n$stackTrace',
        );
      }
    }

    return _localSuggestions(query);
  }

  Future<String> _currentUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to use AI search API');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw StateError('Failed to fetch Firebase ID token');
    }
    return token;
  }

  List<AiSearchResult> _localSuggestions(String query) {
    final normalized = query.trim().isEmpty ? 'Arab business' : query.trim();
    return [
      AiSearchResult(
        title: 'Top picks near you',
        summary:
            'I found three ${normalized.toLowerCase()} options that match your preferences. Al Madina Bistro is trending this week with its “Gulf fusion” tasting menu. Palm Beauty Lounge is offering a “Ramadan Glow” spa package, and Souk Artisan Hub just launched a pop-up for handmade gifts.',
        confidence: 0.87,
      ),
      const AiSearchResult(
        title: 'Why these results?',
        summary:
            'These venues scored highly for rating, recent activity, and owner responsiveness. I also boosted listings with premium plans so you get verified contact and faster support.',
        confidence: 0.68,
      ),
      const AiSearchResult(
        title: 'Next steps',
        summary:
            'Tap any business to open its profile, or ask me something more specific like “family-friendly cafes in Abu Dhabi with outdoor seating”.',
        confidence: 0.52,
      ),
    ];
  }
}
