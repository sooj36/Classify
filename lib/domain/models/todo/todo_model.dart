import 'package:hive/hive.dart';

part 'todo_model.g.dart';
// part 키워드: 물리적으로 분리된 파일이지만 논리적으로는 동일한 파일로 취급함
// 주로 코드 생성기가 만든 파일(memo_model.g.dart)을 현재 파일과 연결할 때 사용함
// 기계가 만든 코드와 사람이 만든 코드를 분리하기 위한 목적으로 쓰였음

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
  final DateTime createdAt; // 생성시간

  @HiveField(1)
  final String todoContent; // 내용

  @HiveField(2)
  final bool? isImportant; // 중요도

  @HiveField(3)
  final bool? isveryImportant; // 중요도

  @HiveField(4)
  final DateTime? lastModified; // 마지막 수정시간

  @HiveField(5)
  final bool? isDone; //  완료여부

  @HiveField(6)
  final String todoId; // 연결된 할일 ID

  TodoModel({
    required this.todoContent,
    this.isImportant = false,
    this.isveryImportant = false,
    this.lastModified,
    DateTime? createdAt,
    this.isDone = false,
    required this.todoId,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoModel copyWith({
    String? todoContent,
    bool? isImportant,
    bool? isveryImportant,
    DateTime? lastModified,
    DateTime? createdAt,
    bool? isDone,
    String? todoId,
  }) =>
      TodoModel(
        todoContent: todoContent ?? this.todoContent,
        isImportant: isImportant ?? this.isImportant,
        isveryImportant: isveryImportant ?? this.isveryImportant,
        lastModified: lastModified ?? this.lastModified,
        createdAt: createdAt ?? this.createdAt,
        isDone: isDone ?? this.isDone,
        todoId: todoId ?? this.todoId,
      );
}
