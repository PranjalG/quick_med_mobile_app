class MedicineCategory {
  final String id;
  final String slug;
  final String name;
  final String? iconAsset;
  final int sortOrder;

  const MedicineCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.iconAsset,
    this.sortOrder = 0,
  });

  factory MedicineCategory.fromJson(Map<String, dynamic> json) {
    return MedicineCategory(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconAsset: json['icon_asset'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineCategory &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}
