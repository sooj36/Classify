import 'dart:math';

import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/ui/study/view_models/study_view_model.dart';
import 'package:classify/ui/study/view/study_detail_page.dart';
import 'package:classify/utils/top_level_setting.dart';

class StudyScreen extends StatefulWidget {
  final StudyViewModel viewModel;

  const StudyScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
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

          final randomStudyMemos = widget.viewModel.randomStudyMemos;

          if (randomStudyMemos.isEmpty) {
            return _buildEmptyState();
          }

          return _buildStudyContent(randomStudyMemos);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              '질문이 있는 공부 메모가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: AppTheme.textColor1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '메모를 작성할 때 질문 필드를 추가하면\n랜덤으로 공부 질문을 볼 수 있습니다',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textColor2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.viewModel.refreshRandomStudyMemos();
              },
              icon: const Icon(Icons.refresh, color: AppTheme.textColor1),
              label: const Center(
                  child: Text('새로고침',
                      style: TextStyle(color: AppTheme.textColor1))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.backgroundColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                  side: BorderSide(
                    color: AppTheme.additionalColor,
                    width: 2,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyContent(List<MemoModel> randomStudyMemos) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...randomStudyMemos
                    .map((memo) => _buildQuestionCard(context, memo)),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.viewModel.refreshRandomStudyMemos();
                    },
                    icon: const Icon(Icons.refresh_outlined,
                        color: AppTheme.pointTextColor),
                    label: const Text('새로고침',
                        style: TextStyle(
                            color: AppTheme.pointTextColor,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // 배경색 흰색으로 변경
                      foregroundColor: AppTheme.primaryColor, // 전경색 변경
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // 라운드 처리
                        side: BorderSide(
                          color: AppTheme.primaryColor, // 테두리 색상
                          width: 2, // 테두리 두께
                        ),
                      ),
                      elevation: 0, // 그림자 제거 (선택사항)
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Random Study Question',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.pointTextColor,
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, MemoModel memo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          _showContentDialog(context, memo);
        },
        onLongPress: () {
          _showDeleteDialog(context, memo);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.question_mark,
                        color: AppTheme.additionalColor),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Question',
                      style: TextStyle(
                        color: Colors.transparent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                memo.question ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '탭하여 답변 보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.touch_app, size: 16, color: AppTheme.textColor2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContentDialog(BuildContext context, MemoModel memo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            memo.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('질문:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor)),
                const SizedBox(height: 8),
                Text(
                  memo.question ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                const Text('답변:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor)),
                const SizedBox(height: 8),
                Text(
                  memo.content,
                  style: const TextStyle(fontSize: 16),
                ),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => StudyDetailPage(
                      memo: memo,
                      viewModel: widget.viewModel,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('상세보기'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, MemoModel memo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('메모 삭제'),
          content: const Text('이 학습 메모를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                widget.viewModel.deleteMemo(memo.memoId, memo.category);
                Navigator.of(context).pop();
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
