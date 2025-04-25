import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';
import 'package:classify/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:classify/ui/archive/archive_view/widgets/buildIdeaDetailPage.dart';
import 'dart:math';
import 'package:classify/utils/top_level_setting.dart';

Widget buildIdeaTabView(Map<String, MemoModel> memos, ArchiveViewModel viewModel) {
  // '아이디어' 카테고리만 필터링
  final ideaMemos = memos.values
      .where((memo) => memo.category == '아이디어')
      .toList();
  
  // 메모가 없는 경우 처리
  if (ideaMemos.isEmpty) {
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
  final latestMemos = List<MemoModel>.from(ideaMemos)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  // 오래된순 메모 리스트 생성
  final oldestMemos = List<MemoModel>.from(ideaMemos)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  // 랜덤 메모 리스트 생성
  final randomMemos = List<MemoModel>.from(ideaMemos.isEmpty 
    ? [] 
    : _getRandomMemos(ideaMemos, 2));
  
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
        // 랜덤 메모 리스트
        SliverToBoxAdapter(
          child: _buildRandomMemoHeader(randomMemosNotifier, viewModel, ideaMemos),
        ),
        
        // 랜덤 메모 표시
        SliverToBoxAdapter(
          child: ValueListenableBuilder<List<MemoModel>>(
            valueListenable: randomMemosNotifier,
            builder: (context, randomList, _) {
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: randomList.length,
                    itemBuilder: (context, index) => ideaCards(
                      context,
                      randomList[index],
                      viewModel,
                    ),
                  ),
                  const Divider(height: 24),
                ],
              );
            },
          ),
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
                  return ideaCards(context, memosList[index], viewModel);
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

Widget _buildRandomMemoHeader(
  ValueNotifier<List<MemoModel>> randomMemos,
  ArchiveViewModel viewModel,
  List<MemoModel> ideaMemos,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        '랜덤 보기',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      TextButton.icon(
        onPressed: () {
          // 랜덤 메모 리스트 갱신
          randomMemos.value = _getRandomMemos(ideaMemos, 2);
        },
        icon: const Icon(Icons.refresh, size: 16, color: AppTheme.primaryColor),
        label: const Text('새로고침', style: TextStyle(color: AppTheme.primaryColor)),
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.primaryColor.withAlpha(26),
        ),
      ),
    ],
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

Widget ideaCards(BuildContext context, MemoModel memo, ArchiveViewModel viewModel) {
  return InkWell(
      onTap: () {
      // GoRouter 대신 일반 Navigator 사용(rootNavigator: true 이 파트가 rootscreen의 appbar & bottomappabar를 가려줌)
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => IdeaDetailPage(
            memo: memo,
            viewModel: viewModel,
          ),
        ),
      );
    },
    onLongPress: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('메모 삭제'),
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
                spacing: 6,
                runSpacing: 6,
                children: memo.tags!.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppTheme.decorationColor1.withAlpha(26),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                )).toList(),
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
  // 비복원 추출: 한번 선택한 항목을 다시 선택 대상에서 제외하여 중복 없이 샘플을 추출하는 방법
  final tempList = List<MemoModel>.from(memos);
  for (int i = 0; i < count; i++) {
    final randomIndex = random.nextInt(tempList.length); // 랜덤 숫자 생성의 핵심
    result.add(tempList[randomIndex]);
    tempList.removeAt(randomIndex); //선택된 메모는 임시 리스트에서 제거(비복원 추출의 핵심)
  }
  
  return result; 
}
