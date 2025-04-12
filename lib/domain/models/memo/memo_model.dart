import 'package:hive/hive.dart';

part 'memo_model.g.dart';

// model을 hive로 생성할 때 절차
// 1. A 모델 클래스 생성
// 2. part 'A_model.g.dart'; 구문을 해당 클래스 파일에 추가
// 3. flutter pub run build_runner build
// 4. A_model.g.dart 파일 생성 확인

// HiveType: 클래스 전체를 Hive에 등록 (어떤 클래스인지)
// HiveField: 클래스 내의 어떤 필드를 저장할지 지정 (클래스의 어떤 속성인지)

@HiveType(typeId: 1)
class MemoModel extends HiveObject {
  
  @HiveField(0)
  final DateTime createdAt;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final bool? isImportant;
  
  @HiveField(4)
  final List<String>? tags;
  
  @HiveField(5)
  final DateTime? lastModified;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final bool? isDone;

  @HiveField(8)
  final String memoId;

  MemoModel({
    required this.title,
    required this.content,
    this.isImportant = false,
    this.tags,
    this.lastModified,
    DateTime? createdAt,
    required this.category,
    this.isDone = false,
    required this.memoId,
  }) : createdAt = createdAt ?? DateTime.now();

  MemoModel copyWith({
    String? title,
    String? content,
    bool? isImportant,
    List<String>? tags,
    DateTime? lastModified,
    DateTime? createdAt,
    String? category,
    bool? isDone,
    String? memoId,
  }) => MemoModel(
    title: title ?? this.title,
    content: content ?? this.content,
    isImportant: isImportant ?? this.isImportant,
    tags: tags ?? this.tags,
    lastModified: lastModified ?? this.lastModified,
    createdAt: createdAt ?? this.createdAt,
    category: category ?? this.category,
    isDone: isDone ?? this.isDone,
    memoId: memoId ?? this.memoId,
  );
}
