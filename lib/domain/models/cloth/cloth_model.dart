

class ClothModel {
  final String? id;          // 옷 고유 ID
  final String imagePath;    // 이미지 경로
  final String? category;    // 카테고리 (상의, 하의 등)
  final String? color;       // 색상
  final String? season;      // 계절
  final DateTime createdAt;  // 생성일
  final String? response;    // 응답
  
  ClothModel({
    this.id,
    required this.imagePath,
    this.category,
    this.color,
    this.season,
    required this.response,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // // JSON 직렬화
  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'imagePath': imagePath,
  //   'category': category,
  //   'color': color,
  //   'season': season,
  //   'createdAt': createdAt.toIso8601String(),
  // };

  // // JSON 역직렬화
  // factory ClothModel.fromJson(Map<String, dynamic> json) => ClothModel(
  //   id: json['id'] as String?,
  //   imagePath: json['imagePath'] as String,
  //   category: json['category'] as String?,
  //   color: json['color'] as String?,
  //   season: json['season'] as String?,
  //   createdAt: DateTime.parse(json['createdAt'] as String),
  // );

  //복사본 생성 (immutable 데이터 수정용)
  //객체의 일부 속성만 수정해서 새로운 객체를 반환하는 메서드
  ClothModel copyWith({
    String? id,
    String? imagePath,
    String? category,
    String? color,
    String? season,
    String? brand,
    DateTime? createdAt,
  }) => ClothModel(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    category: category ?? this.category,
    color: color ?? this.color,
    season: season ?? this.season,
    response: response ?? response,
    createdAt: createdAt ?? this.createdAt,
  );
}