import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/utils/top_level_setting.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.child});
  final Widget child;
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // 오늘을 기본값으로 설정 (이제 0번 인덱스)

  @override
  void initState() {
    super.initState();
    debugPrint("✅ 루트 스크린 초기화");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          context.go(Routes.today);
          break;
        case 1:
          context.go(Routes.archive);
          break;
        case 2:
          context.go(Routes.study);
          break;
        case 3:
          context.go(Routes.profile);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 현재 라우트 경로 가져오기
    final currentRoute = GoRouterState.of(context).matchedLocation;

    // 디버그 출력 추가
    debugPrint('🟢현재 경로: $currentRoute🟢');

    // todo 화면에서만 색상을 다르게 설정
    final appBarColor = currentRoute == Routes.todo
        ? AppTheme.errorColor // TODO 화면
        : AppTheme.primaryColor;

    // 디버그 출력 추가
    debugPrint(
        '🟢AppBar 색상: ${appBarColor == AppTheme.errorColor ? "errorColor" : "primaryColor"}🟢');

    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            context.go(Routes.todo);
          },
          child: Text(
            "할 일 목록",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              context.push(Routes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              context.push(Routes.setting);
            },
          ),
        ],
      ),
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(Routes.sendMemo);
        },
        backgroundColor: AppTheme.accentColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 왼쪽 영역: Today와 Archive
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Today 아이콘
                    IconButton(
                      icon: Icon(
                        Icons.today,
                        color: _selectedIndex == 0
                            ? AppTheme.primaryColor
                            : AppTheme.textColor2,
                        size: 26,
                      ),
                      tooltip: '오늘',
                      onPressed: () => _onItemTapped(0),
                    ),

                    // Archive 아이콘
                    IconButton(
                      icon: Icon(
                        Icons.archive,
                        color: _selectedIndex == 1
                            ? AppTheme.primaryColor
                            : AppTheme.textColor2,
                        size: 26,
                      ),
                      tooltip: '보관함',
                      onPressed: () => _onItemTapped(1),
                    ),
                  ],
                ),
              ),

              // FAB 공간
              const SizedBox(width: 60),

              // 오른쪽 영역: Study와 Profile
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Study 아이콘
                    IconButton(
                      icon: Icon(
                        Icons.school,
                        color: _selectedIndex == 2
                            ? AppTheme.primaryColor
                            : AppTheme.textColor2,
                        size: 26,
                      ),
                      tooltip: '공부',
                      onPressed: () => _onItemTapped(2),
                    ),

                    // Profile 아이콘
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color: _selectedIndex == 3
                            ? AppTheme.primaryColor
                            : AppTheme.textColor2,
                        size: 26,
                      ),
                      tooltip: '프로필',
                      onPressed: () => _onItemTapped(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
