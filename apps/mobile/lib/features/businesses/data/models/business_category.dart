class BusinessCategory {
  const BusinessCategory({required this.id, required this.name, this.parentId});

  factory BusinessCategory.fromMap(String id, Map<String, dynamic> data) {
    return BusinessCategory(
      id: id,
      name: data['name'] as String? ?? '',
      parentId: data['parentId'] as String?,
    );
  }

  final String id;
  final String name;
  final String? parentId;
}
