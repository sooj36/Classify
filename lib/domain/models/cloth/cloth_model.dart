import 'package:hive/hive.dart';
import 'package:cross_file/cross_file.dart';

part 'cloth_model.g.dart';

@HiveType(typeId: 0)
class ClothModel extends HiveObject {
  @HiveField(0)
  final String? id;
  
  @HiveField(1)
  final DateTime createdAt;
  
  @HiveField(2)
  final String? response;
  
  @HiveField(3)
  final String? major;
  
  @HiveField(4)
  final String? minor;
  
  @HiveField(5)
  final String? color;
  
  @HiveField(6)
  final String? material;
  
  @HiveField(7)
  final String? season;
  
  @HiveField(8)
  final String? localImagePath;

  @HiveField(9)
  final String? remoteImagePath;

  @HiveField(10)
  final XFile? file;


  ClothModel({
    this.id,
    this.file,
    this.response,
    this.major,
    this.minor,
    this.color,
    this.material,
    this.season,
    this.localImagePath,
    this.remoteImagePath,
    DateTime? createdAt,
  }) : 
    createdAt = createdAt ?? DateTime.now();

  ClothModel copyWith({
    String? id,
    XFile? file,
    String? major,
    String? minor,
    String? color,
    String? material,
    String? season,
    String? localImagePath,
    String? remoteImagePath,
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
    localImagePath: localImagePath ?? this.localImagePath,
    remoteImagePath: remoteImagePath ?? this.remoteImagePath,
  );
}