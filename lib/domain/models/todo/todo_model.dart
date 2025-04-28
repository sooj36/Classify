import 'package:hive/hive.dart';

part 'todo_model.g.dart';

// model을 hive로 생성할 때 절차
// 1. A 모델 클래스 생성
// 2. part 'A_model.g.dart'; 구문을 해당 클래스 파일에 추가
// 3. flutter pub run build_runner build
// 4. A_model.g.dart 파일 생성 확인

// HiveType: 클래스 전체를 Hive에 등록 (어떤 클래스인지)
// HiveField: 클래스 내의 어떤 필드를 저장할지 지정 (클래스의 어떤 속성인지)

@HiveType(typeId: 2)
class TodoModel extends HiveObject {
  
  @HiveField(0)
  final DateTime createdAt;
  
  @HiveField(1)
  final String todo;
  
  @HiveField(2)
  final bool? isImportant;
  
  @HiveField(3)
  final DateTime? lastModified;
  
  @HiveField(4)
  final bool? isDone;
  
  @HiveField(5)
  final String memoId;

  TodoModel({
    required this.todo,
    this.isImportant = false,
    this.lastModified,
    DateTime? createdAt,
    this.isDone = false,
    required this.memoId,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoModel copyWith({
    String? todo,
    bool? isImportant,
    DateTime? lastModified,
    DateTime? createdAt,
    bool? isDone,
    String? memoId,
  }) => TodoModel(
    todo: todo ?? this.todo,
    isImportant: isImportant ?? this.isImportant,
    lastModified: lastModified ?? this.lastModified,
    createdAt: createdAt ?? this.createdAt,
    isDone: isDone ?? this.isDone,
    memoId: memoId ?? this.memoId,
  );
}
