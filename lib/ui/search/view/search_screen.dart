import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/ui/search/view_model/search_view_model.dart';
import 'package:classify/ui/common/memo_card.dart';
import 'package:classify/utils/top_level_setting.dart';

class SearchScreen extends StatefulWidget {
  final SearchViewModel viewModel;

  const SearchScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.connectStreamToCachedMemos();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    widget.viewModel.search(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterAndSortOptions(),
          _buildSearchResults(),
        ],
      ),
    );
  }

  // 검색창 위젯
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '메모 제목이나 태그로 검색',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppTheme.textColor1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.textColor1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.textColor1, width: 2),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    widget.viewModel.clearSearch();
                  },
                )
              : null,
        ),
      ),
    );
  }

  // 필터 옵션 위젯
  Widget _buildFilterOptions() {
    return Row(
      children: [
        const Text('필터: '),
        const SizedBox(width: 8),
        _buildFilterChip('전체', SearchFilter.all),
        const SizedBox(width: 8),
        _buildFilterChip('제목만', SearchFilter.title),
        const SizedBox(width: 8),
        _buildFilterChip('태그만', SearchFilter.tag),
      ],
    );
  }

  // 정렬 옵션 위젯
  Widget _buildSortOptions() {
    // ValueNotifier 생성 및 초기화
    final ValueNotifier<bool> isLatestSort =
        ValueNotifier<bool>(widget.viewModel.isLatestSort);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('정렬: '),
        const SizedBox(width: 8),
        _buildSortButton(
            isLatestSort: isLatestSort,
            isLatest: true,
            icon: Icons.arrow_downward,
            label: '최신순',
            onPressed: () {
              widget.viewModel.sortByLatest();
              isLatestSort.value = true;
            }),
        const SizedBox(width: 4),
        _buildSortButton(
            isLatestSort: isLatestSort,
            isLatest: false,
            icon: Icons.arrow_upward,
            label: '오래된순',
            onPressed: () {
              widget.viewModel.sortByOldest();
              isLatestSort.value = false;
            }),
      ],
    );
  }

  // 정렬 버튼 위젯
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
            icon: Icon(icon,
                size: 16,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textColor1),
            label: Text(label,
                style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textColor1)),
            style: TextButton.styleFrom(
              backgroundColor: isSelected
                  ? AppTheme.primaryColor.withAlpha(26)
                  : Colors.transparent,
            ),
          );
        });
  }

  // 필터 및 정렬 옵션 위젯
  Widget _buildFilterAndSortOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterOptions(),
          const SizedBox(height: 12),
          _buildSortOptions(),
        ],
      ),
    );
  }

  // 검색 결과 위젯
  Widget _buildSearchResults() {
    return Expanded(
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          // 로딩 중
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 오류 발생
          if (widget.viewModel.error != null) {
            return Center(child: Text('오류: ${widget.viewModel.error}'));
          }

          // 검색어 없음
          if (_searchController.text.isEmpty) {
            return const Center(child: Text('검색어를 입력하세요'));
          }

          final results = widget.viewModel.searchResults;

          // 검색 결과 없음
          if (results.isEmpty) {
            return const Center(child: Text('검색 결과가 없습니다'));
          }

          // 검색 결과 표시
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final memo = results[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: MemoCard(
                  memo: memo,
                  onTap: () => _showMemoDetail(memo),
                  onLongPress: () => _showDeleteDialog(memo.memoId, memo.category),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 필터 칩 위젯
  Widget _buildFilterChip(String label, SearchFilter filter) {
    return ChoiceChip(
      label: Text(label),
      selected: widget.viewModel.searchFilter == filter,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            widget.viewModel.setSearchFilter(filter);
          });
        }
      },
      selectedColor: AppTheme.primaryColor.withAlpha(26),
    );
  }

  // 메모 상세 보기 다이얼로그
  void _showMemoDetail(MemoModel memo) {
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
                // 내용
                Text(memo.content),
                const SizedBox(height: 16),

                // 카테고리
                Row(
                  children: [
                    const Text('카테고리: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(memo.category),
                  ],
                ),

                // 태그
                if (memo.tags != null && memo.tags!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('태그:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: memo.tags!
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor:
                                  AppTheme.primaryColor.withAlpha(26),
                            ))
                        .toList(),
                  ),
                ],

                // 생성 시간
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('생성: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${memo.createdAt.year}/${memo.createdAt.month}/${memo.createdAt.day} ${memo.createdAt.hour}:${memo.createdAt.minute}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // 삭제 다이얼로그
  void _showDeleteDialog(String memoId, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제'),
          content: const Text('이 메모를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                widget.viewModel.deleteMemo(memoId, category);
                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }  
}
