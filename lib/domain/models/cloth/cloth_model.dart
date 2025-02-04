import 'package:cross_file/cross_file.dart';

class ClothModel {
  final XFile? file; // 원본 이미지 파일
  final String? id;          // 옷 고유 ID
  final DateTime createdAt;  // 생성일
  final String? response;    // 응답
  final String? major;       // 대분류
  final String? minor;       // 소분류
  final String? color;       // 색상
  final String? material;    // 소재
  final String? season;      // 계절
  final String? imagePath;   // 이미지 경로
  ClothModel({
    this.id,
    this.file,
    this.response,
    this.major,
    this.minor,
    this.color,
    this.material,
    this.season,
    this.imagePath,
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
    XFile? file,
    String? major,
    String? minor,
    String? color,
    String? material,
    String? season,
    String? imagePath,
    DateTime? createdAt,
  }) => ClothModel(
    id: id ?? this.id,
    file: file ?? this.file,
    major: major ?? this.major,
    minor: minor ?? this.minor,
      color: color ?? this.color,
      material: material ?? this.material,
    season: season ?? this.season,
    createdAt: createdAt ?? this.createdAt,
    imagePath: imagePath ?? this.imagePath,
  );
}