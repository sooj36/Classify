import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 63,
        title: TextButton(
            onPressed: () {
              // todo go
              context.push(Routes.todo);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  // 고화질로 수정 예정
                  'assets/logo_icon.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  "TODO*",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppTheme.pointTextColor,
                  ),
                ),
              ],
            )),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35), // 하단 모서리만 둥글게
          ),
          //
          side: BorderSide(
            color: AppTheme.additionalColor,
            width: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined,
                color: AppTheme.pointTextColor),
            onPressed: () {
              context.push(Routes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppTheme.pointTextColor),
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
        // backgroundColor: AppTheme.additionalColor,
        backgroundColor: Colors.white70,
        elevation: 0,
        shape: const CircleBorder(
          side: BorderSide(
            color: AppTheme.additionalColor,
            // color: Colors.black,
            width: 1.8,
          ),
        ),
        child:
            // Image.asset('assets/logo_icon.png',
            //     width: 30, height: 30, fit: BoxFit.fill)
            const Icon(
          Icons.add_outlined,
          color: Colors.black,
          size: 27,
        ),
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
                        Icons.today_outlined,
                        color: _selectedIndex == 0
                            ? AppTheme.pointTextColor
                            : AppTheme.textColor3,
                        size: 26,
                      ),
                      tooltip: '오늘',
                      onPressed: () => _onItemTapped(0),
                    ),

                    // Archive 아이콘
                    IconButton(
                      icon: Icon(
                        Icons.archive_outlined,
                        color: _selectedIndex == 1
                            ? AppTheme.pointTextColor
                            : AppTheme.textColor3,
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
                        Icons.school_outlined,
                        color: _selectedIndex == 2
                            ? AppTheme.pointTextColor
                            : AppTheme.textColor3,
                        size: 26,
                      ),
                      tooltip: '공부',
                      onPressed: () => _onItemTapped(2),
                    ),

                    // Profile 아이콘
                    IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        color: _selectedIndex == 3
                            ? AppTheme.pointTextColor
                            : AppTheme.textColor3,
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
