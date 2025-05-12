import 'package:flutter/material.dart';
import 'package:classify/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:classify/ui/archive/archive_view/widgets/build_memo_tab_view.dart';
import 'package:classify/utils/top_level_setting.dart';

class ArchiveScreen extends StatefulWidget {
  final ArchiveViewModel viewModel;
  const ArchiveScreen({super.key, required this.viewModel});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    //archiveScreen이 완전히 그려진 후에 fetchMemo를 안전하게 실행하기 위함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initCachedMemos();
      widget.viewModel.connectStreamToCachedMemos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.error != null) {
            return Center(child: Text('에러 발생: ${widget.viewModel.error}'));
          }
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.cachedMemos.isEmpty) {
            return const Center(
              child: Text(
                "메모장이\n비어있습니다",
                style: TextStyle(
                  fontSize: 17,
                  color: AppTheme.textColor2,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          // 데이터 형식 변환
          final memos = widget.viewModel.cachedMemos;
          // clothmodel의 major 값들의 중복을 제거하여 유니크한 리스트 생성하는 코드(향후 동적 카테고리 생성 시 참고를 위해 남겨놓음)
          // final uniqueCategories = memos.values.map((c) => c.category).toSet().toList();
          final uniqueCategories = ["공부", "아이디어", "참조", "회고"];

          return DefaultTabController(
            length: uniqueCategories.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: AppTheme.textColor1,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: uniqueCategories
                      .map((category) => Tab(text: category))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: uniqueCategories.map((category) {
                      // 카테고리별로 다른 위젯 반환
                      switch (category) {
                        case '공부':
                          return buildMemoTabView(
                              memos, widget.viewModel, category);
                        case '아이디어':
                          return buildMemoTabView(
                              memos, widget.viewModel, category);
                        case '참조':
                          return buildMemoTabView(
                              memos, widget.viewModel, category);
                        case '회고':
                          return buildMemoTabView(
                              memos, widget.viewModel, category);
                        default:
                          return Center(child: Text('$category 탭 더미 콘텐츠'));
                      }
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
