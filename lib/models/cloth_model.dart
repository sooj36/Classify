class ClothModel {
  final String? imagePath;
  final DateTime createdAt;
  
  ClothModel({
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}