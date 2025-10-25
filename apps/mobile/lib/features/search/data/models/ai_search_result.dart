class AiSearchResult {
  const AiSearchResult({
    required this.title,
    required this.summary,
    required this.confidence,
  });

  final String title;
  final String summary;
  final double confidence;
}
