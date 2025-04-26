import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';
import 'package:classify/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:classify/ui/archive/archive_view/widgets/build_study_detail_page.dart';
import 'dart:math';
import 'package:classify/utils/top_level_setting.dart';

Widget buildStudyTabView(Map<String, MemoModel> memos, ArchiveViewModel viewModel) {
  // '공부' 카테고리만 필터링
  final studyMemos = memos.values
      .where((memo) => memo.category == '공부')
      .toList();
  
  // 메모가 없는 경우 처리
  if (studyMemos.isEmpty) {
    return const Center(
      child: Text(
        "작성된 메모가 없습니다",
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.textColor2,
        ),
      ),
    );
  }
  
  // 최신순 메모 리스트 생성
  final latestMemos = List<MemoModel>.from(studyMemos)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  // 오래된순 메모 리스트 생성
  final oldestMemos = List<MemoModel>.from(studyMemos)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  
  // 질문이 있는 메모만 필터링(사용자가 임의로 질문을 삭제했을 수도 있기에)
  final questionMemos = studyMemos.where((memo) => memo.question != null && memo.question!.isNotEmpty).toList();
  
  // 랜덤 메모 리스트 생성 (질문이 있는 메모 중에서)
  final randomMemos = questionMemos.isEmpty 
      ? <MemoModel>[] 
      : _getRandomMemos(questionMemos, 1);
  
  // 현재 보여줄 메모 리스트 (기본값은 최신순)
  ValueNotifier<List<MemoModel>> currentMemos = ValueNotifier<List<MemoModel>>(latestMemos);
  
  // 최신순인지 여부를 추적하는 플래그
  ValueNotifier<bool> isLatestSort = ValueNotifier<bool>(true);
  
  // 랜덤 메모 리스트를 위한 ValueNotifier
  ValueNotifier<List<MemoModel>> randomMemosNotifier = ValueNotifier<List<MemoModel>>(randomMemos);

  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
    child: CustomScrollView(
      slivers: [
        // 랜덤 질문 카드 섹션
        if (questionMemos.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildRandomQuestionList(randomMemosNotifier, viewModel, questionMemos),
          ),
        
        // 정렬 버튼
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: AppTheme.decorationColor1,
          automaticallyImplyLeading: false,
          title: _buildSortButtons(isLatestSort, latestMemos, oldestMemos, currentMemos),
        ),
        
        // 메모 리스트
        ValueListenableBuilder<List<MemoModel>>(
          valueListenable: currentMemos,
          builder: (context, memosList, _) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return studyCards(context, memosList[index], viewModel);
                },
                childCount: memosList.length,
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildRandomQuestionList(
  ValueNotifier<List<MemoModel>> randomMemos,
  ArchiveViewModel viewModel,
  List<MemoModel> questionMemos,
) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '오늘의 랜덤 질문',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // 랜덤 메모 리스트 갱신
              randomMemos.value = _getRandomMemos(questionMemos, 1);
            },
            icon: const Icon(Icons.refresh, size: 16, color: AppTheme.primaryColor),
            label: const Text('새로고침', style: TextStyle(color: AppTheme.primaryColor)),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withAlpha(26),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder<List<MemoModel>>(
        valueListenable: randomMemos,
        builder: (context, questionList, _) {
          return Column(
            children: questionList.map((memo) => _buildQuestionCard(context, memo, viewModel)).toList(),
          );
        },
      ),
      const Divider(height: 24),
    ],
  );
}

Widget _buildQuestionCard(BuildContext context, MemoModel memo, ArchiveViewModel viewModel) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12.0),
    color: AppTheme.decorationColor1,
    child: InkWell(
      onTap: () {
        _showContentDialog(context, memo, viewModel);
      },
      onLongPress: () {
        _showDeleteDialog(context, memo, viewModel);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.question_mark, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '질문',
                    style: TextStyle(
                      color: AppTheme.textColor1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memo.question ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '탭하여 답변 보기',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor2,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showContentDialog(BuildContext context, MemoModel memo, ArchiveViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(memo.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('질문:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(memo.question ?? ''),
              const SizedBox(height: 16),
              const Text('답변:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(memo.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => StudyDetailPage(
                    memo: memo,
                    viewModel: viewModel,
                  ),
                ),
              );
            },
            child: const Text('상세보기'),
          ),
        ],
      );
    },
  );
}

void _showDeleteDialog(BuildContext context, MemoModel memo, ArchiveViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('공부 메모 삭제'),
        content: const Text('정말로 이 메모를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteMemo(memo.memoId);
              Navigator.of(context).pop();
            },
            child: const Text('확인', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Widget _buildSortButtons(
  ValueNotifier<bool> isLatestSort,
  List<MemoModel> latestMemos,
  List<MemoModel> oldestMemos,
  ValueNotifier<List<MemoModel>> currentMemos,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        '시간순 보기',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppTheme.textColor1,
        ),
      ),
      Row(
        children: [
          _buildSortButton(
            isLatestSort: isLatestSort, 
            isLatest: true, 
            icon: Icons.arrow_downward, 
            label: '최신순', 
            onPressed: () {
              currentMemos.value = latestMemos;
              isLatestSort.value = true;
            }
          ),
          const SizedBox(width: 4),
          _buildSortButton(
            isLatestSort: isLatestSort, 
            isLatest: false, 
            icon: Icons.arrow_upward, 
            label: '오래된순', 
            onPressed: () {
              currentMemos.value = oldestMemos;
              isLatestSort.value = false;
            }
          ),
        ],
      ),
    ],
  );
}

Widget _buildSortButton({
  required ValueNotifier<bool> isLatestSort,
  required bool isLatest,
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return ValueListenableBuilder<bool>(
    valueListenable: isLatestSort,
    builder: (context, value, _) {
      final bool isSelected = isLatest ? value : !value;
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: isSelected ? AppTheme.primaryColor : AppTheme.textColor1),
        label: Text(label, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.textColor1)),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor.withAlpha(26) : Colors.transparent,
        ),
      );
    }
  );
}

Widget studyCards(BuildContext context, MemoModel memo, ArchiveViewModel viewModel) {
  return InkWell(
    onTap: () {
      // StudyDetailPage로 이동
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => StudyDetailPage(
            memo: memo,
            viewModel: viewModel,
          ),
        ),
      );
    },
    onLongPress: () {
      _showDeleteDialog(context, memo, viewModel);
    },
    child: Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              memo.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            // 내용
            Text(
              memo.content,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // 태그
            if (memo.tags != null && memo.tags!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: memo.tags!.map((tag) => _buildTagItem(tag)).toList(),
              ),
          ],
        ),
      ),
    ),
  );
}

// 랜덤 메모를 가져오는 함수
List<MemoModel> _getRandomMemos(List<MemoModel> memos, int count) {
  final random = Random();
  final result = <MemoModel>[];
  
  // 메모 리스트가 요청 개수보다 작으면 전체 리스트 반환
  if (memos.length <= count) {
    return memos;
  }
  
  // 비복원 추출을 이용하여 중복 없이 랜덤하게 메모 선택
  final tempList = List<MemoModel>.from(memos);
  for (int i = 0; i < count; i++) {
    final randomIndex = random.nextInt(tempList.length);
    result.add(tempList[randomIndex]);
    tempList.removeAt(randomIndex);
  }
  
  return result; 
}

Widget _buildTagItem(String tag) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '#$tag',
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.primaryColor,
      ),
    ),
  );
}
