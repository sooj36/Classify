import 'dart:math';

import 'package:classify/data/repositories/memo/memo_repository.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';

class TodoViewModel extends ChangeNotifier {
  bool _isLatestSort = true;

  // 정렬 (최신순)
  // void sortByLatest() {
  //   _isLatestSort = true;
  //   _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //   notifyListeners();
  // }

  // // 정렬 (오래된순)
  // void sortByOldest() {
  //   _isLatestSort = false;
  //   _todoList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //   notifyListeners();
  // }
}
